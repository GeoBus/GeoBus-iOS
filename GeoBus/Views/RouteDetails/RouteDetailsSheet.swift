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
  @ObservedObject var stopsStorage: StopsStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  @State var isLoading: Bool = false
  
  @State var routeDirection: Int = 0
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: "Route Details")
        
        HStack {
          SelectRouteButton(routesStorage: routesStorage, isLoading: $isLoading)
          Text(routesStorage.selected.name)
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
            self.routesStorage.toggleFavorite(route: self.routesStorage.selected)
          }) {
            RouteDetailsAddToFavorites(routesStorage: routesStorage)
          }
          
        }
        .padding(.horizontal)
        
        HorizontalLine()
          .padding(.vertical, 20)
        
        Picker("Direction", selection: $routeDirection) {
          Text(stopsStorage.stops.first?.name ?? "Ascending").tag(0)
          Text(stopsStorage.stops.last?.name ?? "Descending").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.bottom, 20)
        
        VStack {
          ForEach(stopsStorage.stops) { stop in
            VStack(alignment: .leading) {
              StopButton(stop: stop)
                .padding(.bottom)
              //              VerticalLine(thickness: 2, color: .yellow)
            }
            .padding(.horizontal)
          }
        }
      }
    }
  }
}
