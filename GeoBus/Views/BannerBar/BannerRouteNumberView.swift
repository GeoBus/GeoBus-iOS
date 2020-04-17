//
//  SelectedRouteDisplay.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct BannerRouteNumberView: View {
  
  let backgroundColor: Color = Color(red: 1, green: 0.85, blue: 0)
  
  @Binding var selectedRoute: SelectedRoute
  @Binding var isLoading: Bool
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(backgroundColor)
      
      Text(selectedRoute.routeNumber)
        .font(.title)
        .fontWeight(.heavy)
        .foregroundColor(.black)
      
      if isLoading {
        LoadingView(play: $isLoading)
      }
      
    }
    .frame(width: 80, height: 80)
  }
}
