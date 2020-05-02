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
        
        SheetHeader(title: Text("Find by Route"), toggle: $showSelectRouteSheet)
        
        SelectRouteInput(routesStorage: routesStorage, showSelectRouteSheet: self.$showSelectRouteSheet)
          .padding(.horizontal)
        
        HorizontalLine()
        
        VStack {
          FavoriteRoutes(routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: Text("Trams"), set: routesStorage.trams, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: Text("Neighborhood Buses"), set: routesStorage.neighborhood, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: Text("Night Buses"), set: routesStorage.night, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: Text("Regular Service"), set: routesStorage.regular, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
          SetOfRoutes(title: Text("Elevators"), set: routesStorage.elevators, routesStorage: routesStorage, showSelectRouteSheet: $showSelectRouteSheet)
        }
        
      }
    }
  }
  
  
}


