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

   @StateObject private var mapController = MapController.shared
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared


   var body: some View {
      Map(
         coordinateRegion: $mapController.region,
         interactionModes: [.all],
         showsUserLocation: true,
         annotationItems: mapController.visibleAnnotations
      ) { annotation in

         MapAnnotation(coordinate: annotation.location) {
            switch (annotation.item) {
               case .stop(let item):
                  StopAnnotationView(stop: item)
               case .carris_connection(let item):
                  CarrisConnectionAnnotationView(connection: item)
               case .vehicle(let item):
                  CarrisVehicleAnnotationView(vehicle: item)
            }
         }

      }
      .onReceive(carrisNetworkController.$allStops) { allStopsList in
         self.mapController.createAnnotations(for: allStopsList)
      }
      .onReceive(carrisNetworkController.$allVehicles) { allVehicles in
         self.mapController.createAnnotations(for: allVehicles)
      }
//      .onReceive(carrisNetworkController.$activeVariant) { newVariant in
//         if (newVariant != nil) {
//            self.mapController.updateAnnotations(with: newVariant!)
//         }
//      }
      .onReceive(carrisNetworkController.$activeVehicles) { activeVehicles in
         self.mapController.showAnnotations(for: activeVehicles)
      }
//      .onReceive(mapController.$region.debounce(for: .seconds(0.05), scheduler: DispatchQueue.main)) { newRegion in
//         self.mapController.updateAnnotations(for: newRegion)
//      }
      
   }

}
