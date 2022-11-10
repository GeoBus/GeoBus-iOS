//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {
   
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   @StateObject private var mapController = MapController.shared
   
   @State var annotations: [GeoBusMKAnnotation] = [
//      GeoBusMKAnnotation(id: 120, coordinate: CLLocationCoordinate2D(latitude: 38.736946, longitude: -9.142685), type: .stop),
//      GeoBusMKAnnotation(id: 120, coordinate: CLLocationCoordinate2D(latitude: 38.736946, longitude: -9.142685), type: .stop)
   ]
   
   var body: some View {
      VStack(spacing: 0) {
         ZStack(alignment: .topTrailing) {
            MapViewSwiftUI(
               region: $mapController.region,
               annotations: $annotations
            )
            .edgesIgnoringSafeArea(.vertical)
            .onAppear() {
               print("HOWMANY willAdd Stops: \(carrisNetworkController.allStops.count)")
               for stop in carrisNetworkController.allStops {
                  self.annotations.append(
                     GeoBusMKAnnotation(id: stop.id, coordinate: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lng), type: .stop)
                  )
               }
            }
            VStack(spacing: 15) {
               AboutGeoBus()
               Spacer()
               StopSearch()
               UserLocation()
            }
            .padding()
         }
         NavBar()
            .edgesIgnoringSafeArea(.vertical)
      }
   }
   
}
