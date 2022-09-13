//
//  StopBadge.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopDetailsHeader: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   let stop: RouteVariantStop


   var body: some View {

      HStack(spacing: 15) {

         ZStack {
            switch stop.direction {
               case .ascending:
                  Image("PinkCircle")
               case .descending:
                  Image("OrangeCircle")
               case .circular:
                  Image("BlueCircle")
            }
            Text("\(stop.orderInRoute)")
               .font(.caption)
               .fontWeight(.bold)
               .foregroundColor(Color(.white))
         }

         Text(stop.name)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)

         Spacer()

         Text("\(stop.publicId)")
            .font(Font.system(size: 12, weight: .medium, design: .default) )
            .foregroundColor(Color(.secondaryLabel))
            .padding(.vertical, 2)
            .padding(.horizontal, 7)
            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(colorScheme == .dark ? Color(.secondarySystemFill) : Color(.secondarySystemBackground)))

      }

   }

}
