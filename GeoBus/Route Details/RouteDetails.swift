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
  
  @State var presentRouteDetailsSheet: Bool = false
  
  
  var body: some View {
    
    Button(action: {
      
      if self.routesStorage.state == .routeSelected {

        self.presentRouteDetailsSheet = true
      
      } else if self.routesStorage.state == .error {
      
        self.routesStorage.set(state: .syncing)
      
      }
      
    }) {
      
      RouteDetailsButton(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    
    }
    .disabled( routesStorage.state == .idle || routesStorage.state == .syncing )
    .sheet(isPresented: $presentRouteDetailsSheet) {
      RouteDetailsSheet(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    }
    
  }
  
}
