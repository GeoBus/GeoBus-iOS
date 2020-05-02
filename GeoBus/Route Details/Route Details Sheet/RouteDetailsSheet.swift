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
  
  @Binding var showRouteDetailsSheet: Bool
  
  @State var routeDirection: Int = 0
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: Text("Route Details"), toggle: $showRouteDetailsSheet)
        
        HStack {
          RouteButton(route: routesStorage.selectedRoute!, dimensions: 80)
          Text(routesStorage.getSelectedVariantName())
            .foregroundColor(Color(.label))
            .padding(.leading)
          Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        
        HStack {
          RouteDetailsVehiclesQuantity(vehiclesQuantity: vehiclesStorage.vehicles.count)
            .frame(minWidth: 200)
            .padding(.trailing, 6)
          
          Button(action: {
            TapticEngine.impact.feedback(.heavy)
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
