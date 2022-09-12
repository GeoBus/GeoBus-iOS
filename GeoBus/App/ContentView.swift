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

   @EnvironmentObject var routesController: RoutesController

//   private var mapView = MKMapView()

   @State var selectedStop: RouteVariantStop? = nil

   
   var body: some View {

      VStack(alignment: .trailing, spacing: 0) {

         ZStack(alignment: .trailing) {

            MapView()
               .edgesIgnoringSafeArea(.vertical)

            VStack(alignment: .trailing) {

               if (selectedStop != nil) {
                  StopDetails(
                     canToggle: false,
                     stop: selectedStop!
                  )
                  .padding()
                  .shadow(color: Color(.black).opacity(0.20), radius: 10, x: 0, y: 0)
               }

               Spacer()

//               UserLocation(mapView: mapView)

            }
            .onChange(of: routesController.selectedRouteVariantStop) { newStop in
               self.selectedStop = newStop
            }

         }

         NavBar()

         Divider()

      }

   }

}
