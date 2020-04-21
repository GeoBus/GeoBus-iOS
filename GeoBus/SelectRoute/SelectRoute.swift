//
//  SelectRoute.swift
//  GeoBus
//
//  Created by João on 21/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectRoute: View {
  
  @Binding var selectedRouteNumber: String
  
  @Binding var routesStorage: RoutesStorage
  @ObservedObject var stopsStorage: StopsStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @Binding var isLoading: Bool
  @Binding var isAutoUpdating: Bool
  
  @State var presentRouteSelectionSheet: Bool = false
  @State var presentRouteDetailsSheet: Bool = false
  
  
  var body: some View {
    Button(action: {
      self.presentRouteSelectionSheet = true
      self.isAutoUpdating = false
      self.vehiclesStorage.set(state: .idle)
    }) {
      SelectRouteButton(selectedRouteNumber: self.$selectedRouteNumber, isLoading: self.$isLoading)
    }
    .sheet(
      isPresented: $presentRouteSelectionSheet,
      onDismiss: {
        self.stopsStorage.getStops(for: self.selectedRouteNumber)
        self.vehiclesStorage.set(state: .syncing, route: self.selectedRouteNumber)
    }) {
      SelectRouteSheet(
        selectedRouteNumber: self.$selectedRouteNumber,
        routesStorage: self.$routesStorage,
        presentRouteSelectionSheet: self.$presentRouteSelectionSheet)
    }
  }
}
