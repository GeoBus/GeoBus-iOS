//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteSheet: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: "Find by Route")
        
        SelectRouteInput(routesStorage: routesStorage, presentRouteSelectionSheet: self.$presentRouteSelectionSheet)
          .padding(.horizontal)
        
        HorizontalLine()
        
        VStack {
          FavoriteRoutes(routesStorage: routesStorage, presentRouteSelectionSheet: $presentRouteSelectionSheet)
          AllRoutes(routesStorage: routesStorage, presentRouteSelectionSheet: $presentRouteSelectionSheet)
        }
        
      }
    }
  }
  
  
}


