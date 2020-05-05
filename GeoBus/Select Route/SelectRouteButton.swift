//
//  SelectedRouteDisplay.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteButton: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  
  var body: some View {
    
    ZStack {
      
      if vehiclesStorage.state == .loading {
        
        LoadingView()
        
      } else if vehiclesStorage.state == .error {
        
        RoundedRectangle(cornerRadius: 10)
          .fill(Color(.systemRed).opacity(0.5))
        Image(systemName: "wifi.exclamationmark")
          .font(.title)
          .foregroundColor(Color(.white))
        
      } else {
        
        if routesStorage.isRouteSelected() {
          
          RouteButton(route: routesStorage.selectedRoute!, dimensions: 80)
          
        } else {
          
          RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray4))
          Image(systemName: "plus")
            .font(.title)
            .foregroundColor(Color(.white))
          
        }
        
      }
      
    }
    .frame(width: 80, height: 80)
    .padding(.leading, 15)
    .padding(.trailing, 10)
  }
}
