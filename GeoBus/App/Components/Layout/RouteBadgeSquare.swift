//
//  RouteSelectionSquareView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteBadgeSquare: View {

   let routeNumber: String


   var body: some View {

      ZStack {
         RoundedRectangle(cornerRadius: 10)
            .fill(Globals().getBackgroundColor(for: routeNumber))
         Text(routeNumber)
            .font(Font.system(size: 22, weight: .heavy, design: .default))
            .foregroundColor(Globals().getForegroundColor(for: routeNumber))
      }
      .aspectRatio(1, contentMode: .fit)

   }

}
