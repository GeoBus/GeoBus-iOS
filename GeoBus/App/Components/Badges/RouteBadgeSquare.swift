//
//  RouteSelectionSquareView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteBadgeSquare: View {

   let route: Route

   var body: some View {

      return ZStack {

         RoundedRectangle(cornerRadius: 10)
            .fill(Globals().getBackgroundColor(for: route.kind))

         Text(route.number)
            .font(Font.system(size: 22, weight: .heavy, design: .default))
            .foregroundColor(Globals().getForegroundColor(for: route.kind))

      }
      .aspectRatio(1, contentMode: .fit)

   }

}
