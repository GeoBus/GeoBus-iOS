//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetailsInput: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  
  var body: some View {
    VStack {
      HStack {
        
        Button(action: {
          print("Add To Favorites")
        }) {
          Text("Add to Favorites")
            .font(.system(size: 30, weight: .bold, design: .default))
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.yellow)
        .cornerRadius(10)
      }
    }
  }
}
