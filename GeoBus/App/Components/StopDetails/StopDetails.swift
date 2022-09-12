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

   @State var canToggle: Bool
   @State var isOpen = false
   @State var stop: RouteVariantStop

   var content: some View {
      VStack(spacing: 0) {
         // The header of the view is always visible
         StopBadge(
            name: stop.name,
            orderInRoute: stop.orderInRoute,
            direction: stop.direction
         )
         .padding()

         // Estimations are visible only if the view is opened
         // or if the view cannot be toggled.
         if (isOpen || !canToggle) {
            VStack {
               Divider()
               StopEstimations(publicId: stop.publicId)
            }
         }
      }
      .background(isOpen
                  ? (colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemBackground))
                  : (colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
      )
      .cornerRadius(10)

   }


   var body: some View {

      if (canToggle) {
         // If the view can be opened and closed,
         // then it should be wrapped by a button view.
         Button(action: {
            self.isOpen = !self.isOpen
            TapticEngine.impact.feedback(.medium)
         }) {
            content
               .transaction { transaction in
                  transaction.animation = nil
               }
         }

      } else {
         // If it cannot be toggled,
         // then it is a normal view.
         content
      }

   }

}
