//
//  BannerRouteDirectionsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsButton: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  var body: some View {
    
    VStack {
      
      if routesStorage.state == .idle {
        
        ChooseRouteMessage()
        
      } else if routesStorage.state == .syncing {
        
        SyncingRoutesMessage()
        
      } else if routesStorage.state == .error {
        
         ConnectionErrorMessage()
        
      } else if routesStorage.state == .routeSelected {
        
        VStack(alignment: .leading) {
          HStack {
            LiveIcon()
            if vehiclesStorage.vehicles.count == 1 {
              Text("1 active vehicle")
                .font(Font.system(size: 11, weight: .medium, design: .default) )
                .lineLimit(1)
                .foregroundColor(Color(.secondaryLabel))
            } else {
              Text("\(vehiclesStorage.vehicles.count) active vehicles")
                .font(Font.system(size: 11, weight: .medium, design: .default) )
                .lineLimit(1)
                .foregroundColor(Color(.secondaryLabel))
            }
            Spacer()
            Text("+info")
              .font(Font.system(size: 10, weight: .medium, design: .default) )
              .foregroundColor(Color(.secondaryLabel))
              .padding(.vertical, 2)
              .padding(.horizontal, 7)
              .background(RoundedRectangle(cornerRadius: 10).foregroundColor(colorScheme == .dark ? Color(.systemGray4) : Color(.systemGray6)))
          }

          Text(routesStorage.getSelectedVariantName())
            .font(.body)
            .fontWeight(.bold)
            .lineLimit(nil)
            .foregroundColor(Color(.label))
            .padding(.bottom, 0)

          Spacer()
        }
        
      }
      
    }
    .padding(.vertical)
    .padding(.horizontal, 10)
    
  }
}
