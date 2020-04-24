//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import Grid

struct RouteDetailsSheet: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @State var routeDirection: Int = 0
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: "Route Details")
        
        HStack {
          SelectRouteButton(routesStorage: routesStorage)
          Text(routesStorage.selectedRoute?.name ?? "-")
          Spacer()
        }
        .padding(.vertical)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(10)
        .padding(.horizontal)
        
        HStack {
          RouteDetailsVehiclesQuantity(vehiclesQuantity: vehiclesStorage.vehicles.count)
            .frame(minWidth: 200)
            .padding(.trailing, 6)
          
          Button(action: {
            self.routesStorage.toggleFavorite(route: self.routesStorage.selectedRoute)
          }) {
            RouteDetailsAddToFavorites(routesStorage: routesStorage)
          }
          
        }
        .padding(.horizontal)
        
        HorizontalLine()
          .padding(.top, 20)
        
        if routesStorage.selectedRoute?.variants.count ?? 0 > 1 {
          RouteVariantPicker(routesStorage: routesStorage)
            .padding(.top, 12)
          HorizontalLine()
        }
        
        RouteVariantStops(routesStorage: routesStorage)
          .padding(.top, 20)
        
      }
    }
  }
}
