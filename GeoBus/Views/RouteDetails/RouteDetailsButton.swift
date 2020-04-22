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
  @ObservedObject var stopsStorage: StopsStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  var body: some View {
    
    VStack {
      
      if routesStorage.isSelected() {
        VStack(alignment: .leading) {
          HStack {
            LiveConnectionIcon()
              .padding(.leading, -2)
            Text("Live")
              .font(Font.system(size: 11, weight: .medium, design: .default) )
              .foregroundColor(.green)
              .padding(.leading, -5)
            Text("\(vehiclesStorage.vehicles.count) \(vehiclesStorage.vehicles.count == 1 ? "vehicle" : "vehicles" ) in circulation")
              .font(Font.system(size: 11, weight: .medium, design: .default) )
              .foregroundColor(.secondary)
            Spacer()
          }
          
          Text(routesStorage.selected.name)
            .font(.body)
            .fontWeight(.bold)
            .lineLimit(nil)
            .foregroundColor(.black)
          
          Spacer()
        }
        
      } else {
        
        HStack {
          LeftArrow()
            .padding(.leading, -2)
          Text("Choose a Route")
            .font(Font.system(size: 15, weight: .bold, design: .default))
            .foregroundColor(.black)
          Spacer()
        }
        
      }
    }
    .padding(.vertical)
    .padding(.horizontal, 10)
    
    
  }
}
