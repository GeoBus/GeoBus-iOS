//
//  BannerBarView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct ActionBannerView: View {
  
  @Binding var selectedRoute: SelectedRoute
  
  @Binding var isLoading: Bool
  @Binding var isRefreshingVehicleStatuses: Bool
  
  @Binding var showRouteSelectionSheet: Bool
  @Binding var showRouteDetailsSheet: Bool
  
  let geoBusAPI: GeoBusAPI
  
  
  var body: some View {
    HStack {
      Button(action: {
        self.showRouteSelectionSheet = true
        self.isRefreshingVehicleStatuses = false
      }) {
        RouteSelectionButtonView(selectedRoute: self.$selectedRoute,isLoading: self.$isLoading)
      }
      .sheet(
        isPresented: $showRouteSelectionSheet,
        onDismiss: {
          self.geoBusAPI.getVehicleStatuses()
      }) {
        RouteSelectionSheetView(selectedRoute: self.$selectedRoute, showRouteSelectionSheet: self.$showRouteSelectionSheet)
      }
      
      ActionBannerDivider()
      
      Button(action: {
        self.showRouteDetailsSheet = true
        print("RouteDetailsButtonView()")
      }) {
        RouteDetailsButtonView()
      }.sheet(
        isPresented: $showRouteDetailsSheet,
        onDismiss: {
//          self.geoBusAPI.getVehicleStatuses()
      }) {
        RouteDetailsSheetView(selectedRoute: self.$selectedRoute, showRouteDetailsSheet: self.$showRouteDetailsSheet)
      }
      
      Spacer()
    }
    .frame(maxHeight: 115)
    .padding(.top, -7)
    .padding(.bottom, -10)
  }
}


struct DetailsView: View {
  var body: some View {
    VStack {
      Text("Hello world")
    }
  }
}
