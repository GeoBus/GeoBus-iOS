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
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color(.systemYellow))
      
      Text(route.number.prefix(3))
        .font(Font.system(size: 20, weight: .heavy, design: .default))
        .foregroundColor(.black)
      
    }
    .frame(width: 60, height: 60)
  }
}
