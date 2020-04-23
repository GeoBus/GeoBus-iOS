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
  
  @Binding var isLoading: Bool
  @Binding var isAutoUpdating: Bool
  
  @State var presentRouteSelectionSheet: Bool = false
  
  
  var body: some View {
    Button(action: {
      self.presentRouteSelectionSheet = true
      self.isAutoUpdating = false
      self.vehiclesStorage.set(state: .idle)
    }) {
      SelectRouteButton(routesStorage: routesStorage, isLoading: self.$isLoading)
    }
    .sheet(
      isPresented: $presentRouteSelectionSheet,
      onDismiss: {
        self.vehiclesStorage.set(route: self.routesStorage.selectedRoute?.number ?? "", state: .syncing)
    }) {
      SelectRouteSheet(
        routesStorage: self.routesStorage,
        presentRouteSelectionSheet: self.$presentRouteSelectionSheet)
    }
  }
}
