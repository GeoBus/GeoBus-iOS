//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine
import MapKit

struct ContentView : View {
  
  @State var selectedRoute = Route(routeNumber: "", name: "")
  
  @State var availableRoutes = AvailableRoutes()
  @State var annotationsStore = AnnotationsStore()
  
  @State var isLoading = false
  @State var isAutoUpdating = false
  
  private let timeBetweenRefreshes: CGFloat = 10 // seconds
  private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  
  
  var body: some View {
    
    let geoBusAPI = GeoBusAPI(
      selectedRoute: $selectedRoute,
      availableRoutes: $availableRoutes,
      annotationsStore: $annotationsStore,
      isLoading: $isLoading,
      isAutoUpdating: $isAutoUpdating
    )
    
    return VStack {
      MapView(
        selectedRoute: $selectedRoute,
        annotationsStore: $annotationsStore
      ).edgesIgnoringSafeArea(.top)
        .onReceive(timer) { input in
          if self.isAutoUpdating {
            geoBusAPI.getVehicles()
          }
      }
      

      
      ActionBannerView(
        selectedRoute: $selectedRoute,
        availableRoutes: $availableRoutes,
        isLoading: $isLoading,
        isAutoUpdating: $isAutoUpdating,
        geoBusAPI: geoBusAPI
      )
      //      .alert(isPresented: self.$showInvalidRouteAlert) {
      //        Alert(
      //          title: Text("Route does not exist"),
      //          message: Text("The route '\(selectedRoute)' does not exist. Maybe fix the typo?"),
      //          dismissButton: .default(Text("OK"))
      //        )
      //      }
      
      RefreshStatusView(interval: timeBetweenRefreshes, isAutoUpdating: $isAutoUpdating)
    }
  }
}
