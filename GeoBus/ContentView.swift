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
  
  @State var selectedRoute = SelectedRoute()
  @State var vehicleAnnotations: [MapAnnotation] = []
  @State var mapView = MKMapView()
  
  @State var isLoading = false
  @State var isRefreshingVehicleStatuses = false
  
  @State var showNoVehiclesFoundAlert = false
  @State var showRouteSelectionSheet = false
  @State var showRouteDetailsSheet = false
  
  let timeBetweenRefreshes: CGFloat = 10 // seconds
  let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  
  
  // MARK: -
  
  var body: some View {
    
    let geoBusAPI = GeoBusAPI(
      vehicleAnnotations: self.$vehicleAnnotations,
      isLoading: self.$isLoading,
      isRefreshingVehicleStatuses: self.$isRefreshingVehicleStatuses,
      showNoVehiclesFoundAlert: self.$showNoVehiclesFoundAlert,
      routeNumber: self.selectedRoute.routeNumber
    )
    
    return VStack {
      MapView(mapView: $mapView, vehicleAnnotations: $vehicleAnnotations)
        .onReceive(timer) { input in
          if self.isRefreshingVehicleStatuses {
            geoBusAPI.getVehicleStatuses()
          }
      }
      .alert(isPresented: self.$showNoVehiclesFoundAlert) {
        Alert(
          title: Text("No Buses"),
          message: Text("There are no buses in that route right now. Maybe take a walk?"),
          dismissButton: .default(Text("OK"))
        )
      }
      
      ActionBannerView(
        selectedRoute: self.$selectedRoute,
        isLoading: self.$isLoading,
        isRefreshingVehicleStatuses: self.$isRefreshingVehicleStatuses,
        showRouteSelectionSheet: self.$showRouteSelectionSheet,
        showRouteDetailsSheet: self.$showRouteDetailsSheet,
        geoBusAPI: geoBusAPI
      )
      
      RefreshStatusView(interval: timeBetweenRefreshes, isRefreshingVehicleStatuses: $isRefreshingVehicleStatuses)
    }
    .edgesIgnoringSafeArea(.top)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
