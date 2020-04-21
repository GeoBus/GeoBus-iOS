//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteSheet: View {
  
  @Binding var selectedRouteNumber: String
  @Binding var routesStorage: RoutesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: "Find by Route")
        
        SelectRouteInput(
          selectedRouteNumber: self.$selectedRouteNumber,
          presentRouteSelectionSheet: self.$presentRouteSelectionSheet
        )
          .padding(.horizontal)
        
        HorizontalLine()
        
        VStack {
          AllRoutes(
            selectedRouteNumber: $selectedRouteNumber,
            routesStorage: $routesStorage,
            presentRouteSelectionSheet: $presentRouteSelectionSheet
          )
         
          FavoriteRoutes(
            selectedRouteNumber: $selectedRouteNumber,
            routesStorage: $routesStorage,
            presentRouteSelectionSheet: $presentRouteSelectionSheet
          )
        }
      }
    }
  }
  
  
}


