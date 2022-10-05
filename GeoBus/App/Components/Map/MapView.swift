//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import Map
import MapKit
import Combine

struct MapView: View {

   @EnvironmentObject var mapController: MapController
   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController
   
   
   var body: some View {
      
      Map(
         coordinateRegion: $mapController.region,
         interactionModes: [.pan, .zoom],
         annotationItems: mapController.visibleAnnotations,
         annotationContent: { item in
            let annotation = UpdatingMapAnnotation(coordinate: item.location, publisher: item.$location)
            ViewMapAnnotation(annotation: annotation) {
               switch (item.format) {
               case .stop:
                  StopAnnotationView(stop: item.stop!, isPresentedOnAppear: false)
               case .vehicle:
                  VehicleAnnotationView(vehicle: item.vehicle!, isPresentedOnAppear: false)
               case .singleStop:
                  StopAnnotationView(stop: item.stop!, isPresentedOnAppear: true)
               }
            }
         }
      )
      .onChange(of: stopsController.selectedStop) { newStop in
         if (newStop != nil) {
            mapController.updateAnnotations(with: newStop!)
         }
      }
      .onChange(of: routesController.selectedVariant) { newVariant in
         if (newVariant != nil) {
            mapController.updateAnnotations(with: newVariant!)
         }
      }
      .onChange(of: vehiclesController.vehicles) { newVehiclesList in
         mapController.updateAnnotations(with: newVehiclesList)
      }
      
      
      //            Map(
      //                coordinateRegion: $mapController.region,
      //                interactionModes: [.all],
      //                showsUserLocation: true,
      //                annotationItems: mapController.visibleAnnotations
      //            ) { annotation in
      //
//                      ViewMapAnnotation(coordinate: annotation.location) {
//                          switch (annotation.format) {
//                          case .stop:
//                              StopAnnotationView(stop: annotation.stop!, isPresentedOnAppear: false)
//                          case .vehicle:
//                              VehicleAnnotationView(vehicle: annotation.vehicle!, isPresentedOnAppear: false)
//                          case .singleStop:
//                              StopAnnotationView(stop: annotation.stop!, isPresentedOnAppear: true)
//                          }
//                      }
      //
      //            }
                  
      
   }
   
   
}




@objc
class UpdatingMapAnnotation: NSObject, MKAnnotation {
   
   dynamic var coordinate: CLLocationCoordinate2D
   
   private var coordinateCancellable: Cancellable?
   
   init<P: Publisher>(coordinate: CLLocationCoordinate2D, publisher: P) where P.Output == CLLocationCoordinate2D, P.Failure == Never {
      self.coordinate = coordinate
      
      super.init()
      
      coordinateCancellable = publisher
         .sink { [weak self] newValue in
            // I changed unowned to weak, since we are now in another async context
            // and the instance could (although highly unlikely) be gone until the animation is performed
            UIView.animate(withDuration: 0.25) {
               self?.coordinate = newValue
            }
         }
   }
   
}
