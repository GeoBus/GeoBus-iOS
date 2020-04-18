//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsSheetView: View {
  
  @Binding var selectedRoute: SelectedRoute
  @Binding var showRouteDetailsSheet: Bool
  
  var body: some View {
    NavigationView {
      Form {
        TextField("Route Number (ex. 758)", text: self.$selectedRoute.routeNumber)
        Button(action: { self.showRouteDetailsSheet = false }) { Text("Locate") }
      }
      .navigationBarTitle("Route \(selectedRoute.routeNumber) Details")
      .navigationBarItems(trailing: Button( action: { self.showRouteDetailsSheet = false }) { Text("Done") })
      .padding(.top, 30)
      
    }
  }
}
