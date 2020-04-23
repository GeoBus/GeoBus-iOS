//
//  RouteSelectionRecentRoutesView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Grid

struct FavoriteRoutes: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    VStack {
      Text("Favorite Routes")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
        .padding(.top, 20)
      
      HorizontalLine(color: .white)
      
      VStack {
        
        if routesStorage.favorites.count > 0 {
          
          Grid(routesStorage.favorites) { route in
            Button(action: {
              self.routesStorage.select(route: route)
              self.presentRouteSelectionSheet = false
            }){
              RouteButton(route: route)
            }
          }
          .gridStyle(ModularGridStyle(columns: .min(70), rows: .fixed(70)))
          
        } else if routesStorage.favorites.count == 0 && routesStorage.isSelected() {
          
          Text("Add \(routesStorage.selected.routeNumber) to your favorites.")
          
        } else { Text("You have no favorite routes.") }
        
      }
      .padding(.top, 5)
      .padding(.bottom)
      .padding(.horizontal)
      
    }
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
    .cornerRadius(15)
    .padding()
  }
}
