//
//  RouteDetails.swift
//  GeoBus
//
//  Created by João on 21/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetails: View {
  
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
      self.presentRouteDetailsSheet = true
      print("RouteDetailsButtonView()")
    }) {
      RouteDetailsButton()
    }
    .sheet(
      isPresented: $presentRouteDetailsSheet)
    {
      RouteDetails(
        selectedRouteNumber: self.$selectedRouteNumber,
        routesStorage: self.$routesStorage,
        stopsStorage: self.stopsStorage,
        vehiclesStorage: self.vehiclesStorage,
        isLoading: self.$isLoading,
        isAutoUpdating: self.$isAutoUpdating
      )
    }
    
  }
}
