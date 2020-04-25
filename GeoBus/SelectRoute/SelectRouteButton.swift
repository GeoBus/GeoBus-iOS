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
    
    return ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill( routesStorage.isSelected() ? Color(.systemYellow) : Color(.systemGray4) )
      
      if routesStorage.isSelected() {
        Text(routesStorage.getSelectedRouteNumber())
          .font(.title)
          .fontWeight(.heavy)
          .foregroundColor(.black)
      } else {
        Image(systemName: "plus")
          .font(.title)
          .foregroundColor(Color(.white))
      }
      
      if routesStorage.isLoading {
        LoadingView()
      }
      
    }
    .frame(width: 80, height: 80)
    .padding(.leading, 15)
    .padding(.trailing, 10)
  }
}
