//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView : View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @ObservedObject var routesStorage = RoutesStorage()
  @ObservedObject var vehiclesStorage = VehiclesStorage()
  
  
  var body: some View {
    
    VStack {
      
      MapView(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        .edgesIgnoringSafeArea(.vertical)
        .padding(.bottom, -10)
      
      HStack {
        SelectRoute(
          routesStorage: routesStorage,
          vehiclesStorage: vehiclesStorage
        )
        
        VerticalLine(thickness: 2)
        
        RouteDetails(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        
        Spacer()
      }
      .frame(height: 115)
      .background(colorScheme == .dark ? Color(.systemGray5) : Color(.white))
      
//      RefreshStatusView(interval: timeBetweenRefreshes, isAutoUpdating: $isAutoUpdating)
      
    }
  }
}
