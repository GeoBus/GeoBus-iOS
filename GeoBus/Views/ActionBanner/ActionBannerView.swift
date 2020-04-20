//
//  BannerBarView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct ActionBannerView: View {
  
  @Binding var selectedRoute: Route
  @Binding var availableRoutes: AvailableRoutes
  
  @Binding var isLoading: Bool
  @Binding var isAutoUpdating: Bool
  
  @State var presentRouteSelectionSheet: Bool = false
  @State var presentRouteDetailsSheet: Bool = false
  
  let geoBusAPI: GeoBusAPI
  
  
  var body: some View {
    HStack {
      Button(action: {
        self.presentRouteSelectionSheet = true
        self.isAutoUpdating = false
        self.geoBusAPI.getRoutes()
      }) {
        RouteSelectionButtonView(selectedRoute: self.$selectedRoute, isLoading: self.$isLoading)
      }
      .sheet(
        isPresented: $presentRouteSelectionSheet,
        onDismiss: {
          self.geoBusAPI.getStops()
          self.geoBusAPI.getVehicles()
      }) {
        RouteSelectionSheetView(
          selectedRoute: self.$selectedRoute,
          availableRoutes: self.$availableRoutes,
          presentRouteSelectionSheet: self.$presentRouteSelectionSheet)
      }
      
      VerticalLine(thickness: 3)
      
      Button(action: {
        self.presentRouteDetailsSheet = true
        print("RouteDetailsButtonView()")
      }) {
        RouteDetailsButtonView()
      }
      .sheet(
        isPresented: $presentRouteDetailsSheet)
      {
        RouteDetailsSheetView(selectedRoute: self.$selectedRoute, presentRouteDetailsSheet: self.$presentRouteDetailsSheet)
      }
      
      Spacer()
    }
    .frame(maxHeight: 115)
    .padding(.top, -7)
    .padding(.bottom, -10)
  }
}
