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

   @EnvironmentObject var mapController: MapController
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController


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
               case .carris_vehicle(let item):
                  CarrisVehicleAnnotationView(vehicle: item)
               case .carris_connection(let item):
                  CarrisConnectionAnnotationView(connection: item)
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
            self.mapController.updateAnnotations(with: carrisNetworkController.activeVehicles)
         }
      }
      .onChange(of: carrisNetworkController.allVehicles) { newVehiclesList in
         print("GB6: activeVehicles HAS CHANGED")
         self.mapController.updateAnnotations(with: carrisNetworkController.update())
      }
   }

}
