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
   
   @StateObject private var mapController = MapController.shared
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      VStack(spacing: 0) {
         ZStack(alignment: .topTrailing) {
            MapViewSwiftUI(
               region: $mapController.region,
               camera: $mapController.mapCamera,
               annotations: $mapController.allAnnotations,
               overlays: $mapController.allOverlays
            )
            .edgesIgnoringSafeArea(.vertical)
            .onReceive(carrisNetworkController.$activeVariant) { newVariant in
               if (newVariant != nil) {
                  if (newVariant?.circularShape != nil) {
                     var tempLinePoints: [CLLocationCoordinate2D] = []
                     do {
                        let dataStringData = Data(newVariant!.circularShape!.utf8)
                        let dataObject = try JSONDecoder().decode(CarrisAPIModel.Shape2.self, from: dataStringData)
                        print("HJBUYY/TGUYINUHBGVFCTVYGBUHNJHBGVFCDVTGYBHUN")
                        print(dataObject)
                        for point in dataObject.coordinates {
                           tempLinePoints.append(
                              CLLocationCoordinate2D(latitude: point[1], longitude: point[0])
                           )
                        }
                     } catch {
                        print(error)
                     }
                     self.mapController.allOverlays.append(
                        MKPolyline(coordinates: tempLinePoints, count: tempLinePoints.count)
                     )
                  }
               }
            }
            .onReceive(carrisNetworkController.$activeVehicles) { newVehiclesList in
               var tempNewAnnotations: [GeoBusMKAnnotation] = []
               for vehicle in carrisNetworkController.activeVehicles {
                  tempNewAnnotations.append(
                     GeoBusMKAnnotation(
                        type: .vehicle,
                        id: vehicle.id,
                        coordinate: CLLocationCoordinate2D(latitude: vehicle.lat ?? 0, longitude: vehicle.lng ?? 0)
                     )
                  )
               }
               mapController.add(annotations: tempNewAnnotations, ofType: .vehicle)
            }
            .onReceive(mapController.$region) { newRegion in
               var tempNewAnnotations: [GeoBusMKAnnotation] = []
               if (newRegion.span.latitudeDelta < 0.01 || newRegion.span.longitudeDelta < 0.01) {
                  
                  let latTop = newRegion.center.latitude + newRegion.span.latitudeDelta + 0.01
                  let latBottom = newRegion.center.latitude - newRegion.span.latitudeDelta - 0.01
                  
                  let lngRight = newRegion.center.longitude + newRegion.span.longitudeDelta + 0.01
                  let lngLeft = newRegion.center.longitude - newRegion.span.longitudeDelta - 0.01
                  
                  for stop in carrisNetworkController.allStops {
                     
                     let isBetweenLats = stop.lat > latBottom && stop.lat < latTop
                     let isBetweenLngs = stop.lng > lngLeft && stop.lng < lngRight
                     
                     if (isBetweenLats && isBetweenLngs) {
                        tempNewAnnotations.append(
                           GeoBusMKAnnotation(
                              type: .stop,
                              id: stop.id,
                              coordinate: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lng)
                           )
                        )
                     }
                     
                  }
               }
               mapController.add(annotations: tempNewAnnotations, ofType: .stop)
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
