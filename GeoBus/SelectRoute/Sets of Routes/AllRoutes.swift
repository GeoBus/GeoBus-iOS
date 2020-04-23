//
//  RouteSelectionRecentRoutesView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Grid

struct AllRoutes: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    VStack {
      
      Text("All Routes")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
        .padding(.top, 20)
      
      HorizontalLine(color: .white)
      
      Grid(self.routesStorage.all) { route in
        Button(action: {
          self.routesStorage.select(route: route)
          self.presentRouteSelectionSheet = false
        }){
          RouteButton(route: route)
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
