//
//  BannerRouteDirectionsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsButton: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  
  var body: some View {
    
    VStack {
      
      if vehiclesStorage.state == .error {
        
        ConnectionErrorScreen()
        
      } else {
        
        if routesStorage.isRouteSelected() {
          
          SelectedRouteScreen(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
          
        } else {
          
          ChooseRouteScreen()
          
        }
        
      }
      
    }
    .padding(.vertical)
    .padding(.trailing, 10)
    
  }
}
