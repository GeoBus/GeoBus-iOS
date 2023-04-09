//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetailsAddToFavorites: View {

   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared


   var body: some View {
      VStack {
         Image(systemName: "heart.fill")
            .font(.system(size: 30, weight: .bold, design: .default))
            .foregroundColor(carrisNetworkController.isActiveRouteFavourite() ? Color(.white) : Color(.systemRed))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(carrisNetworkController.isActiveRouteFavourite() ? Color(.systemRed) : Color("BackgroundSecondary"))
      .cornerRadius(10)
      .aspectRatio(1, contentMode: .fit)
      .frame(width: 120)
   }
}
