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
  
  @Binding var showSelectRouteSheet: Bool
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: "Find by Route")
        
        SelectRouteInput(routesStorage: routesStorage, showSelectRouteSheet: self.$showSelectRouteSheet)
          .padding(.horizontal)
        
        HorizontalLine()
        
        VStack {
          FavoriteRoutes(routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: "Trams", set: routesStorage.trams, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: "Neighborhood Buses", set: routesStorage.neighborhood, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: "Night Buses", set: routesStorage.night, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: "Regular Service", set: routesStorage.regular, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: "Elevators", set: routesStorage.elevators, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
        }
        
      }
    }
  }
  
  
}


