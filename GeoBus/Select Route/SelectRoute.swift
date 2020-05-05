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
      if self.vehiclesStorage.state == .error {
        self.vehiclesStorage.set(state: .active)
      } else {
        self.showSelectRouteSheet = true
      }
    }) {
      SelectRouteButton(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
    }
    .sheet(
      isPresented: $showSelectRouteSheet,
      onDismiss: {
        self.vehiclesStorage.set(route: self.routesStorage.getSelectedRouteNumber())
        self.vehiclesStorage.set(state: .active)
    }) {
      
      SelectRouteSheet(routesStorage: self.routesStorage, showSelectRouteSheet: self.$showSelectRouteSheet)
      
    }
    
  }
}
