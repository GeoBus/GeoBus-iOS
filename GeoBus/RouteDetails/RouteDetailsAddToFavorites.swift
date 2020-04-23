//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetailsAddToFavorites: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  
  var body: some View {
    VStack {
      Image(systemName: routesStorage.isFavorite(route: routesStorage.selectedRoute) ? "star.slash" : "star.fill")
        .font(.system(size: 30, weight: .bold, design: .default))
        .foregroundColor(.yellow)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
    .cornerRadius(10)
  }
}
