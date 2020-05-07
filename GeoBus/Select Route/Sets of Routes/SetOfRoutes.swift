//
//  SetOfRoutes.swift
//  GeoBus
//
//  Created by João on 27/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import Grid

struct SetOfRoutes: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
    
  var title: Text
  var set: [Route]
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var showSelectRouteSheet: Bool
  
  
  var body: some View {
  
    VStack {
      
      title
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(Color(.label))
        .padding(.top, 20)
      
      HorizontalLine() //color: .white
      
      Grid(set) { route in
        
        Button(action: {
          self.routesStorage.select(route: route)
          self.showSelectRouteSheet = false
        }){
          RouteButton(route: route, dimensions: 60)
        }
        
      }
      .gridStyle(ModularGridStyle(columns: .min(70), rows: .fixed(70)))
      .padding(.top, 5)
      .padding(.bottom)
      .padding(.horizontal)
      
    }
    .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
    .cornerRadius(15)
    .padding()
    
  }
  
}
