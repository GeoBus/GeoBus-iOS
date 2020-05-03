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
      
      ZStack(alignment: .top) {
        
        MapView(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
          .edgesIgnoringSafeArea(.vertical)
          .padding(.bottom, -10)
        
        if routesStorage.isStopSelected() {
          StopDetails(
            publicId: routesStorage.selectedStopAnnotation?.publicId ?? "",
            name: routesStorage.selectedStopAnnotation?.name ?? "-",
            orderInRoute: routesStorage.selectedStopAnnotation?.orderInRoute ?? -1,
            direction: routesStorage.selectedStopAnnotation?.direction ?? .ascending,
            isOpen: true
          )
            .padding()
            .shadow(radius: 10)
        }
        
      }
      
      HStack {
        SelectRoute(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        RouteDetails(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        Spacer()
      }
      .frame(height: 115)
      .background(colorScheme == .dark ? Color(.systemGray5) : Color(.white))
      
    }
    
  }
  
}
