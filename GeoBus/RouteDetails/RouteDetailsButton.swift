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
      
      if routesStorage.isSelected() {
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
            Text("info")
              .font(Font.system(size: 10, weight: .medium, design: .default) )
              .foregroundColor(Color(.secondaryLabel))
              .padding(.vertical, 2)
              .padding(.horizontal, 7)
              .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(.systemGray6)))
          }
          
          Text(routesStorage.getSelectedVariantName())
            .font(.body)
            .fontWeight(.bold)
            .lineLimit(nil)
            .foregroundColor(Color(.label))
            .padding(.bottom, 0)
          
          Spacer()
        }
        
      } else if routesStorage.isLoading {
        
        HStack {
          Text("Syncing Routes...")
            .font(Font.system(size: 15, weight: .bold, design: .default))
            .foregroundColor(Color(.tertiaryLabel))
          Spacer()
        }
        
      } else {
        
        HStack {
          Text("← Choose a Route")
            .font(Font.system(size: 15, weight: .bold, design: .default))
            .foregroundColor(Color(.secondaryLabel))
          Spacer()
        }
        
      }
    }
    .padding(.vertical)
    .padding(.horizontal, 10)
    
  }
}
