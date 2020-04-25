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
      if self.routesStorage.isSelected() {
        self.presentRouteDetailsSheet = true
      }
    }) {
      RouteDetailsButton(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    }
    .disabled(!routesStorage.isSelected())
    .sheet(isPresented: $presentRouteDetailsSheet) {
      RouteDetailsSheet(routesStorage: self.routesStorage, vehiclesStorage: self.vehiclesStorage)
    }
    
  }
  
}
