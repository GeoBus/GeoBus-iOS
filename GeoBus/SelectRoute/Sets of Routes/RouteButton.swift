//
//  RouteSelectionSquareView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteButton: View {
  
  let route: Route
  private let activeColor: Color = Color(red: 1, green: 0.85, blue: 0)
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(activeColor)
      
      Text(route.number.prefix(3))
        .font(Font.system(size: 20, weight: .heavy, design: .default))
        .foregroundColor(.black)
      
    }
    .frame(width: 60, height: 60)
  }
}
