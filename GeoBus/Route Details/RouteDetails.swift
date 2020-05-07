//
//  RouteDetails.swift
//  GeoBus
//
//  Created by João on 21/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetails: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @Binding var showSelectRouteSheet: Bool
  
  @State var showRouteDetailsSheet: Bool = false
  
  var body: some View {
    
    Button(action: {
      if self.vehiclesStorage.state == .error {
        self.vehiclesStorage.set(state: .active)
      } else {
        if self.routesStorage.isRouteSelected() {
          self.showRouteDetailsSheet = true
        }
      }
    }) {
      RouteDetailsButton(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    }
    .disabled(!routesStorage.isRouteSelected())
    .sheet(isPresented: $showRouteDetailsSheet) {
      RouteDetailsSheet(
        routesStorage: self.routesStorage,
        vehiclesStorage: self.vehiclesStorage,
        showSelectRouteSheet: self.$showSelectRouteSheet,
        showRouteDetailsSheet: self.$showRouteDetailsSheet
      )
    }
    
  }
  
}
