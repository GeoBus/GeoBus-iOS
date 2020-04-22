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
  @ObservedObject var stopsStorage: StopsStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @Binding var isLoading: Bool
  @Binding var isAutoUpdating: Bool
  
  @State var presentRouteDetailsSheet: Bool = false
  
  
  var body: some View {
    
    Button(action: { self.presentRouteDetailsSheet = true }) {
      RouteDetailsButton(
        routesStorage: self.routesStorage,
        stopsStorage: self.stopsStorage,
        vehiclesStorage: self.vehiclesStorage
      )
    }
    .sheet(
      isPresented: $presentRouteDetailsSheet)
    {
      RouteDetailsSheet(
        routesStorage: self.routesStorage,
        stopsStorage: self.stopsStorage,
        vehiclesStorage: self.vehiclesStorage,
        presentRouteSelectionSheet: self.$presentRouteDetailsSheet
      )
    }
    
  }
}
