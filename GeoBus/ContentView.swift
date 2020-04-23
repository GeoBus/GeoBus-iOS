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

struct ContentView : View {
  
  @ObservedObject var routesStorage = RoutesStorage()
  @ObservedObject var stopsStorage = StopsStorage()
  @ObservedObject var vehiclesStorage = VehiclesStorage()
  
  @State var isLoading = false
  @State var isAutoUpdating = false
  
  private let timeBetweenRefreshes: CGFloat = 10 // seconds
  
  
  var body: some View {
    
    VStack {
      
      MapView(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        .edgesIgnoringSafeArea(.top)
      
      HStack {
        SelectRoute(
          routesStorage: routesStorage,
          vehiclesStorage: vehiclesStorage,
          isLoading: $isLoading,
          isAutoUpdating: $isAutoUpdating
        )
        
        VerticalLine(thickness: 3)
        
        RouteDetails(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        
        Spacer()
      }
      .frame(maxHeight: 115)
      .padding(.top, -7)
      .padding(.bottom, -10)
      
//      RefreshStatusView(interval: timeBetweenRefreshes, isAutoUpdating: $isAutoUpdating)
      
    }
  }
}
