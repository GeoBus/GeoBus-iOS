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

   @EnvironmentObject var routesController: RoutesController


   var body: some View {
      VStack {
         Image(systemName: "heart.fill")
            .font(.system(size: 30, weight: .bold, design: .default))
            .foregroundColor(routesController.isFavourite(route: routesController.selectedRoute!) ? Color(.white) : Color(.systemRed))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(routesController.isFavourite(route: routesController.selectedRoute!)
                  ? Color(.systemRed)
                  : colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
      )
      .cornerRadius(10)
      .aspectRatio(1, contentMode: .fit)
      .frame(width: 120)
   }
}
