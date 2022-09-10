//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine
import MapKit

struct ContentView: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @ObservedObject var routesStorage = RoutesStorage()
   @ObservedObject var vehiclesStorage = VehiclesStorage()

   @EnvironmentObject var routesController: RoutesController

   @State var mapView = MKMapView()

   @State var showSelectRouteSheet: Bool = false

   var body: some View {

      VStack {

         ZStack(alignment: .topTrailing) {

            //            MapView(mapView: $mapView, selectedRouteVariantStopAnnotations: routesController.selectedRouteVariantStopAnnotations, vehiclesStorage: vehiclesStorage)
            NewMap()
               .edgesIgnoringSafeArea(.vertical)
               .padding(.bottom, -10)

            UserLocation(mapView: $mapView)

            if (routesController.selectedRouteVariantStop != nil) {
               StopDetails()
                  .padding()
                  .shadow(color: Color(.black).opacity(0.20), radius: 10, x: 0, y: 0)
            }

         }

         HStack {
            SelectRoute(vehiclesStorage: vehiclesStorage, showSelectRouteSheet: $showSelectRouteSheet)
            RouteDetails(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage, showSelectRouteSheet: $showSelectRouteSheet)
            Spacer()
         }
         .frame(height: 115)
         .background(colorScheme == .dark ? Color(.systemGray5) : Color(.white))

      }

   }

}
