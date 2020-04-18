//
//  SelectedRouteDisplay.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteSelectionButtonView: View {
  
  private let activeColor: Color = Color(red: 1, green: 0.85, blue: 0)
  private let disabledColor: Color = Color(red: 0.95, green: 0.95, blue: 0.95)
  
  @Binding var selectedRoute: SelectedRoute
  @Binding var isLoading: Bool
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill( (selectedRoute.routeNumber.count != 0) ? activeColor : disabledColor )
      
      if(selectedRoute.routeNumber.count != 0) {
        Text(selectedRoute.routeNumber.prefix(3))
          .font(.title)
          .fontWeight(.heavy)
          .foregroundColor(.black)
      } else {
        Image(systemName: "plus.circle.fill")
          .foregroundColor(.black)
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
