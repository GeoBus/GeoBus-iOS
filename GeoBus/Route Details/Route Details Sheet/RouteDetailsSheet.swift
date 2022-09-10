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
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @Binding var showSelectRouteSheet: Bool
  @Binding var showRouteDetailsSheet: Bool
  
  @State var routeDirection: Int = 0

   @StateObject var routesController = RoutesController()
  
  var body: some View {
    
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: Text("Route Details"), toggle: $showRouteDetailsSheet)
        
        HStack {
          Button(action: {
            self.showRouteDetailsSheet = false
            self.showSelectRouteSheet = true
          }) {
             RouteButton(route: routesController.allRoutes[0], dimensions: 80)
          }
          Text(routesStorage.getSelectedVariantName())
            .foregroundColor(Color(.label))
            .padding(.leading)
          Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
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
        
        StopsList(routesStorage: routesStorage)
          .padding(.top, 20)
        
      }
    }
    .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
    .edgesIgnoringSafeArea(.bottom)
    
  }
}
