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
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var showSelectRouteSheet: Bool
  
  @State var routeNumberToRemove = ""
  @State var showConfirmRemoveFromFavorites: Bool = false
  
  var body: some View {
    VStack {
      Text("Favorite Routes")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(Color(.label))
        .padding(.top, 20)
      
      HorizontalLine()
      
      VStack {
        
        if routesStorage.favorites.count > 0 {
          
          Grid(routesStorage.favorites) { route in
            RouteButton(route: route, dimensions: 60)
              .onTapGesture(perform: {
                self.routesStorage.select(route: route)
                self.showSelectRouteSheet = false
              })
              .onLongPressGesture(perform: {
                self.routeNumberToRemove = route.number
                self.showConfirmRemoveFromFavorites = true
              })
              .alert(isPresented: self.$showConfirmRemoveFromFavorites, content: {
                Alert(
                  title: Text("Remove \(self.routeNumberToRemove) from Favorites?"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Remove")) {
                    self.routesStorage.toggleFavorite(route: self.routesStorage.findRoute(from: self.routeNumberToRemove))
                  }
                )
              })
          }
          .gridStyle(ModularGridStyle(columns: .min(70), rows: .fixed(70)))
          
        } else {
          
          Text("You have no favorite routes.")
          
        }
        
      }
      .padding(.top, 5)
      .padding(.bottom)
      .padding(.horizontal)
      
    }
    .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
    .cornerRadius(15)
    .padding()
  }
}
