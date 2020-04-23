//
//  SelectedRouteDisplay.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteButton: View {
  
  private let activeColor: Color = Color(red: 1, green: 0.85, blue: 0)
  private let disabledColor: Color = Color(red: 0.95, green: 0.95, blue: 0.95)
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var isLoading: Bool
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill( routesStorage.isSelected() ? activeColor : disabledColor )
      
      if routesStorage.isSelected() {
        Text(routesStorage.selectedRoute?.number ?? "-")
          .font(.title)
          .fontWeight(.heavy)
          .foregroundColor(.black)
      } else {
        Image(systemName: "plus")
          .font(.title)
          .foregroundColor(.secondary)
      }
      
      if isLoading {
        LoadingView(play: $isLoading)
      }
      
    }
    .frame(width: 80, height: 80)
    .padding(.leading, 15)
    .padding(.trailing, 10)
  }
}
