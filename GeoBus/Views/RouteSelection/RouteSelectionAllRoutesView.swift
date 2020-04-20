//
//  RouteSelectionRecentRoutesView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Grid

struct RouteSelectionAllRoutesView: View {
  
  @Binding var selectedRoute: Route
  @Binding var availableRoutes: AvailableRoutes
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    VStack {
      Text("All Routes")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
        .padding(.top, 20)
      
      HorizontalLine(color: .white)
      
      Grid(availableRoutes.all) { route in
        Button(action: {
          self.selectedRoute = route
          self.presentRouteSelectionSheet = false
        }){
          RouteSelectionSquareView(route: route)
        }
      }
    .gridStyle(ModularGridStyle(columns: .min(70), rows: .fixed(70)))
      .padding(.top, 5)
      .padding(.bottom)
      .padding(.horizontal)
    }
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
    .cornerRadius(15)
    .padding()
  }
}
