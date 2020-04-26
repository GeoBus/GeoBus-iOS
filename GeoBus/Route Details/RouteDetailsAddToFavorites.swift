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
      Image(systemName: "star.fill")
        .font(.system(size: 30, weight: .bold, design: .default))
        .foregroundColor(routesStorage.isFavorite(route: routesStorage.selectedRoute) ? Color(.white) : Color(.systemOrange))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(routesStorage.isFavorite(route: routesStorage.selectedRoute) ? Color(.systemOrange) : Color(.secondarySystemBackground))
    .cornerRadius(10)
  }
}
