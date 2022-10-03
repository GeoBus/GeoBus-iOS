//
//  RouteBadgePill.swift
//  GeoBus
//
//  Created by João on 29/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteBadgePill: View {

   let routeNumber: String

   var body: some View {

      VStack {
         Text(routeNumber)
            .font(.footnote)
            .fontWeight(.heavy)
            .lineLimit(1)
            .foregroundColor(Globals().getForegroundColor(for: routeNumber))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
      }
      .background(Globals().getBackgroundColor(for: routeNumber))
      .cornerRadius(10)

   }

}
