//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var mapController: MapController
   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController


   var body: some View {
      Map(
         coordinateRegion: $mapController.region,
         interactionModes: [.all],
         showsUserLocation: true,
         annotationItems: mapController.visibleAnnotations
      ) { annotation in

         MapAnnotation(coordinate: annotation.location) {
            switch (annotation.format) {
               case .stop:
                  StopAnnotationView(stop: annotation.stop!, isPresentedOnAppear: false)
               case .vehicle:
                  VehicleAnnotationView(vehicle: annotation.vehicle!, isPresentedOnAppear: false)
               case .singleStop:
                  StopAnnotationView(stop: annotation.stop!, isPresentedOnAppear: true)
            }
         }

      }
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
   }


}
