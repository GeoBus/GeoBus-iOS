//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetailsAddToFavorites: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @ObservedObject var routesStorage: RoutesStorage
  
  
  var body: some View {
    VStack {
      Image(systemName: "heart.fill")
        .font(.system(size: 30, weight: .bold, design: .default))
        .foregroundColor(routesStorage.isFavorite(route: routesStorage.selectedRoute) ? Color(.white) : Color(.systemRed))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(routesStorage.isFavorite(route: routesStorage.selectedRoute)
      ? Color(.systemRed)
      : colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
    )
    .cornerRadius(10)
  }
}
