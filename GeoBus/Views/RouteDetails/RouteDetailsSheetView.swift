//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsSheetView: View {
  
  @Binding var selectedRoute: Route
  @Binding var presentRouteDetailsSheet: Bool
  
  var body: some View {
    NavigationView {
      Form {
        TextField("Route Number (ex. 758)", text: self.$selectedRoute.routeNumber)
        Button(action: { self.presentRouteDetailsSheet = false }) { Text("Locate") }
      }
      .navigationBarTitle("Route \(selectedRoute.routeNumber) Details")
      .navigationBarItems(trailing: Button( action: { self.presentRouteDetailsSheet = false }) { Text("Done") })
      .padding(.top, 30)
      
    }
  }
}
