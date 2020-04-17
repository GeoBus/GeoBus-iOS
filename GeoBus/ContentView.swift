//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView : View {
  
  @State var routeSelectionMode = false
  
  @State var selectedRoute = SelectedRoute()
  @State var isLoading = false
  
  @State var vehicleLocations = VehicleLocations()
  
  // MARK: -
  
  var body: some View {
    VStack {
      
      MapView(isLoading: $isLoading, vehicleLocations: $vehicleLocations)

      Button(action: {
        self.routeSelectionMode = true
      }) {
        BannerBarView(selectedRoute: self.$selectedRoute, isLoading: self.$isLoading)
      }
      .sheet(
        isPresented: $routeSelectionMode,
        onDismiss: {
          GeoBusAPI(routeNumber: self.selectedRoute.routeNumber, vehicleLocations: self.$vehicleLocations, isLoading: self.$isLoading)
            .getVehicleStatuses()
      }) {
        RouteSelectionView(routeSelectionMode: self.$routeSelectionMode, selectedRoute: self.$selectedRoute)
        
        //        CardContentsView(vehicleStore: VehicleStore(), vehicleAnotations: self.$mapAnnotations, mapWasUpdated: self.$mapWasUpdated)
      }
    }
    .edgesIgnoringSafeArea(.vertical)
  }
}
