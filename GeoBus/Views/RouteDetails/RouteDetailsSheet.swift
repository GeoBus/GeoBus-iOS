//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import Grid

struct RouteDetailsSheet: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var stopsStorage: StopsStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack {
        
        SheetHeader(title: "Route Details")
        
        RouteDetailsInput(routesStorage: routesStorage)
          .padding()
        
        HorizontalLine()
        
        VStack {
          ForEach(stopsStorage.stops) { stop in
            VStack(alignment: .leading) {
              Text(stop.name ?? "-")
                .fontWeight(.bold)
              Text(stop.publicId ?? "-")
              HorizontalLine()
            }
            .padding(.horizontal)
          }
        }
      }
    }
  }
}
