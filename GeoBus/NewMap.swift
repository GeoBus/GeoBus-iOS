//
//  NewMap.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import MapKit

struct IdentifiablePlace: Identifiable {
   let id: UUID
   let location: CLLocationCoordinate2D
   init(id: UUID = UUID(), lat: Double, long: Double) {
      self.id = id
      self.location = CLLocationCoordinate2D(
         latitude: lat,
         longitude: long)
   }
}

struct NewMap: View {

   @EnvironmentObject var routesController: RoutesController

   @State var lisbonArea = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732),
      latitudinalMeters: 15000, longitudinalMeters: 15000
   )

   var body: some View {

      Map(coordinateRegion: $lisbonArea, showsUserLocation: true, annotationItems: routesController.selectedStops) { place in
         MapAnnotation(coordinate: place.location) {
            if (routesController.selectedRouteVariantStop != nil && routesController.selectedRouteVariantStop!.id == place.id) {
               Image("GreenInfo")
                  .onTapGesture {
                     routesController.select(stop: nil)
                  }
            } else {
               Image("OrangeArrowDown")
                  .onTapGesture {
                     routesController.select(stop: place)
                  }
            }
         }
      }
      .onTapGesture {
         if (routesController.selectedRouteVariantStop != nil) {
            routesController.select(stop: nil)
         }
      }
   }
}
