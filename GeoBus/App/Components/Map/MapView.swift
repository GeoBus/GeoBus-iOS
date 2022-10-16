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
            switch (annotation.format) {
               case .carris_stop:
                  CarrisStopAnnotationView(stop: annotation.carris_stop!)
               case .carris_vehicle:
                  CarrisVehicleAnnotationView(vehicle: annotation.carris_vehicle!)
               case .carris_connection:
                  CarrisConnectionAnnotationView(connection: annotation.carris_connection!)
            }
         }

      }
      .onChange(of: carrisNetworkController.selectedStop) { newStop in
         if (newStop != nil) {
            self.mapController.updateAnnotations(with: newStop!)
         }
      }
      .onChange(of: carrisNetworkController.selectedVariant) { newVariant in
         if (newVariant != nil) {
            self.mapController.updateAnnotations(with: newVariant!)
            self.mapController.updateAnnotations(with: carrisNetworkController.allVehicles, for: carrisNetworkController.selectedRoute?.number)
         }
      }
      .onChange(of: carrisNetworkController.allVehicles) { newVehiclesList in
         self.mapController.updateAnnotations(with: newVehiclesList, for: carrisNetworkController.selectedRoute?.number)
      }
   }

}
