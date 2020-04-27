//
//  SelectRoute.swift
//  GeoBus
//
//  Created by João on 21/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectRoute: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @State var showSelectRouteSheet: Bool = false
  
  
  var body: some View {
    
    Button(action: {
      
      if self.routesStorage.state == .idle || self.routesStorage.state == .routeSelected {

        self.showSelectRouteSheet = true
        self.vehiclesStorage.set(state: .idle)
      
      } else if self.routesStorage.state == .error {
      
        self.routesStorage.set(state: .syncing)
      
      }
      
    }) {
      
      SelectRouteButton(routesStorage: routesStorage)
      
    }
    .disabled( routesStorage.state == .syncing )
    .sheet(
      isPresented: $showSelectRouteSheet,
      onDismiss: {
        self.vehiclesStorage.set(route: self.routesStorage.getSelectedRouteNumber(), state: .syncing)
    }) {
      
      SelectRouteSheet(routesStorage: self.routesStorage, showSelectRouteSheet: self.$showSelectRouteSheet)
      
    }
    
  }
}
