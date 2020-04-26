//
//  SelectedRouteDisplay.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteButton: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  
  var body: some View {
    
    ZStack {
      
      RoundedRectangle(cornerRadius: 10)
        .fill( routesStorage.state == .routeSelected ? Color(.systemYellow) : Color(.systemGray4) )
      
      if routesStorage.state == .idle {
        
        Image(systemName: "plus")
          .font(.title)
          .foregroundColor(Color(.white))
        
      } else if routesStorage.state == .syncing {
        
        LoadingView()
        
      } else if routesStorage.state == .error {
        
        Image(systemName: "bolt.slash.fill")
          .font(.title)
          .foregroundColor(Color(.white))
        
      } else if routesStorage.state == .routeSelected {
        
        Text(routesStorage.getSelectedRouteNumber())
          .font(.title)
          .fontWeight(.heavy)
          .foregroundColor(.black)
        
      }
      
    }
    .frame(width: 80, height: 80)
    .padding(.leading, 15)
    .padding(.trailing, 10)
  }
}
