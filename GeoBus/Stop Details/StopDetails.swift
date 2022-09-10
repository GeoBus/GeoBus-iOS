//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct StopDetails: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var routesController: RoutesController

   @State var isOpen = false

   var body: some View {

      Button(action: {
         self.isOpen = !self.isOpen
         TapticEngine.impact.feedback(.medium)
      }) {

         VStack {

            StopBadge(
               name: "-",
               orderInRoute: -1,
               direction: .ascending
            )
               .padding()

            VStack {
               if isOpen {
                  HorizontalLine()
//                  StopEstimations(publicId: self.publicId)
               }
            }
            .padding(.top, -12)

         }
         .background(isOpen
                     ? (colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemBackground))
                     : (colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
         )
         .cornerRadius(10)
         .padding(.bottom, isOpen ? 15 : 0)

      }

   }

}
