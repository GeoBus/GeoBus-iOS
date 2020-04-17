//
//  BannerBarView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct BannerBarView: View {
  
  @Binding var selectedRoute: SelectedRoute
  @Binding var isLoading: Bool
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.white)
//        .clipped()
//        .shadow(radius: 2)
      
      HStack {
        BannerRouteNumberView(selectedRoute: $selectedRoute, isLoading: $isLoading)
          .padding()
//          .position(x: 50, y: 50)
        
        VStack {
          BannerSingleRouteDirectionView()
            .accentColor(.green)
          BannerSingleRouteDirectionView()
            .accentColor(.blue)
        }
        .padding()
        Spacer()
      }
      
    }
    .frame(width: UIScreen.main.bounds.width, height: 100)
  }
}
