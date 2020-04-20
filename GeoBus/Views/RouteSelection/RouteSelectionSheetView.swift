//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteSelectionSheetView: View {
  
  @Binding var selectedRoute: Route
  @Binding var availableRoutes: AvailableRoutes
  
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        VStack {
          RouteSelectionHeaderView()
          RouteSelectionTextFieldAndButtonView(
            selectedRoute: self.$selectedRoute,
            presentRouteSelectionSheet: self.$presentRouteSelectionSheet
          )
        }.padding(.horizontal)
        HorizontalLine()
        VStack {
          RouteSelectionAllRoutesView(
            selectedRoute: $selectedRoute,
            availableRoutes: $availableRoutes,
            presentRouteSelectionSheet: $presentRouteSelectionSheet
          )
        }
      }
    }
  }
  
  
}


