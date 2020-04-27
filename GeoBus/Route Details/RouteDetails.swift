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
  
  @State var showRouteDetailsSheet: Bool = false
  
  
  var body: some View {
    
    Button(action: {
      
      if self.routesStorage.state == .routeSelected {

        self.showRouteDetailsSheet = true
      
      } else if self.routesStorage.state == .error {
      
        self.routesStorage.set(state: .syncing)
      
      }
      
    }) {
      
      RouteDetailsButton(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    
    }
    .disabled( routesStorage.state == .idle || routesStorage.state == .syncing )
    .sheet(isPresented: $showRouteDetailsSheet) {
      RouteDetailsSheet(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    }
    
  }
  
}
