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

   @ObservedObject var mapController = MapController.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared


   var body: some View {
      Map(
         coordinateRegion: $mapController.region,
         interactionModes: [.all],
         showsUserLocation: true,
         annotationItems: mapController.visibleAnnotations
      ) { annotation in

         MapAnnotation(coordinate: annotation.location) {
            switch (annotation.item) {
               case .carris_stop(let item):
                  CarrisStopAnnotationView(stop: item)
               case .carris_connection(let item):
                  CarrisConnectionAnnotationView(connection: item)
               case .carris_vehicle(let item):
                  CarrisVehicleAnnotationView(vehicle: item)
            }
         }

      }
      .onChange(of: carrisNetworkController.activeStop) { newStop in
         if (newStop != nil) {
            self.mapController.updateAnnotations(with: newStop!)
         }
      }
      .onChange(of: carrisNetworkController.activeVariant) { newVariant in
         if (newVariant != nil) {
            self.mapController.updateAnnotations(with: newVariant!)
         }
      }
//      .onChange(of: carrisNetworkController.activeVehicle) { newVehicle in
//         if (newVehicle != nil) {
//            self.mapController.updateAnnotations(with: newVehicle!)
//         }
//      }
      .onChange(of: carrisNetworkController.activeVehicles) { newVehiclesList in
         self.mapController.updateAnnotations(with: newVehiclesList)
      }
      
   }

}
