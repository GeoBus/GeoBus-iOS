//
//  SelectedRouteScreen.swift
//  GeoBus
//
//  Created by João on 27/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectedRouteScreen: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  
  var body: some View {
    
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
        .lineLimit(2)
        .foregroundColor(Color(.label))
        .padding(.bottom, 0)
      
      Spacer()
    }
    
  }
  
}
