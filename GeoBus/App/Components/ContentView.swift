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
   
   var body: some View {
      VStack(spacing: 0) {
         ZStack(alignment: .topTrailing) {
            MapViewSwiftUI(
               region: $mapController.region,
               annotations: $mapController.newAnnotations
            )
            .edgesIgnoringSafeArea(.vertical)
//            .onAppear() {
//            .onReceive(mapController.$region.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)) { newRegion in
            .onChange(of: mapController.region, perform: { newRegion in
               var tempNewAnnotations: [GeoBusMKAnnotation] = []
               if (newRegion.span.latitudeDelta < 0.01 || newRegion.span.longitudeDelta < 0.01) {
                  
                  let latTop = newRegion.center.latitude + newRegion.span.latitudeDelta
                  let latBottom = newRegion.center.latitude - newRegion.span.latitudeDelta
                  
                  let lngRight = newRegion.center.longitude + newRegion.span.longitudeDelta
                  let lngLeft = newRegion.center.longitude - newRegion.span.longitudeDelta
                  
                  for stop in carrisNetworkController.allStops {
                     
                     let isBetweenLats = stop.lat > latBottom && stop.lat < latTop
                     let isBetweenLngs = stop.lng > lngLeft && stop.lng < lngRight
                     
                     if (isBetweenLats && isBetweenLngs) {
                        tempNewAnnotations.append(
                           GeoBusMKAnnotation(type: .stop, id: stop.id, coordinate: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lng))
                        )
                     }
                  }
               }
//               mapController.newAnnotations.removeAll()
               mapController.newAnnotations = tempNewAnnotations
            })
//            .onChange(of: mapController.$region, perform: { newRegion in
//            .onReceive(mapController.$region.debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)) { newRegion in
//               if (newRegion.span.latitudeDelta < 0.005 || newRegion.span.longitudeDelta < 0.005) {
//                  
//                  var tempMatchingAnnotations: [GeoBusMKAnnotation] = []
//                  
//                  let latTop = newRegion.center.latitude + newRegion.span.latitudeDelta
//                  let latBottom = newRegion.center.latitude - newRegion.span.latitudeDelta
//                  
//                  let lngRight = newRegion.center.longitude + newRegion.span.longitudeDelta
//                  let lngLeft = newRegion.center.longitude - newRegion.span.longitudeDelta
//                  
//                  
//                  for stop in carrisNetworkController.allStops {
//                     
//                     // Checks
//                     let isBetweenLats = stop.lat > latBottom && stop.lat < latTop
//                     let isBetweenLngs = stop.lng > lngLeft && stop.lng < lngRight
//                     
//                     if (isBetweenLats && isBetweenLngs) {
//                        tempMatchingAnnotations.append(
//                           GeoBusMKAnnotation(
//                              id: stop.id,
//                              coordinate: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lng),
//                              type: .stop
//                           )
//                        )
//                     }
//                     
//                  }
//                  
//                  mapController.newAnnotations = tempMatchingAnnotations
//                  
//               } else {
//                  mapController.newAnnotations.removeAll()
//               }
//            }
            
            
            
            
            
            
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
