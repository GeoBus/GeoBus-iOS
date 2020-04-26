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
        .foregroundColor(Color(.label))
        .padding(.top, 20)
      
      HorizontalLine() //color: .white
      
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
    .background(Color(.secondarySystemBackground))
    .cornerRadius(15)
    .padding()
    
  }
}
