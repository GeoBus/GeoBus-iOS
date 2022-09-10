//
//  RouteSelectionSquareView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteButton: View {

   let route: RouteFinal
   let dimensions: CGFloat

   var body: some View {

      let backgroundColor: Color
      let foregroundColor: Color

      switch route.kind {
         case .tram:
            backgroundColor = Color(red: 1.00, green: 0.85, blue: 0.00)
            foregroundColor  = Color(.black)
            break
         case .neighborhood:
            backgroundColor = Color(red: 1.00, green: 0.55, blue: 0.40)
            foregroundColor  = Color(.white)
            break
         case .night:
            backgroundColor = Color(red: 0.12, green: 0.35, blue: 0.70)
            foregroundColor  = Color(.white)
            break
         case .elevator:
            backgroundColor = Color(red: 0.00, green: 0.60, blue: 0.40)
            foregroundColor  = Color(.white)
            break
         case .regular:
            backgroundColor = Color(red: 1.00, green: 0.75, blue: 0.00)
            foregroundColor  = Color(.black)
            break
      }


      return ZStack {

         RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)

         Text(route.number)
            .font(Font.system(size: dimensions/3, weight: .heavy, design: .default))
            .foregroundColor(foregroundColor)

      }
      .frame(width: dimensions, height: dimensions)

   }

}
