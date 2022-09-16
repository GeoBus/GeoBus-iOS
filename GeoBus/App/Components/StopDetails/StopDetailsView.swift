//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct StopDetailsView: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme
   
   @EnvironmentObject var estimationsController: EstimationsController

   let refreshTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()

   let canToggle: Bool
   let publicId: String
   let name: String
   let orderInRoute: Int?
   let direction: Direction?

   @State private var isOpen = false
   @State private var estimations: [Estimation]? = nil


   func getEstimationsFromController() {
      Task {
         self.estimations = await estimationsController.get(for: self.publicId)
      }
   }


   var fixedHeader: some View {
      HStack(spacing: 15) {
         ZStack {
            switch direction {
               case .ascending:
                  Image("PinkCircle")
               case .descending:
                  Image("OrangeCircle")
               case .circular:
                  Image("BlueCircle")
               case .none:
                  Image("BlueCircle")
            }
            Text(String(orderInRoute ?? 0))
               .font(.caption)
               .fontWeight(.bold)
               .foregroundColor(Color(.white))
         }
         Text(name)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)
         Spacer()
         Text(String(publicId))
            .font(Font.system(size: 12, weight: .medium, design: .default) )
            .foregroundColor(Color(.secondaryLabel))
            .padding(.vertical, 2)
            .padding(.horizontal, 7)
            .background(colorScheme == .dark ? Color(.secondarySystemFill) : Color(.secondarySystemBackground))
            .cornerRadius(10)
      }
   }



   var content: some View {
      StopEstimations(estimations: self.estimations)
         .onAppear() {
            // Get estimations when view appears
            self.getEstimationsFromController()
         }
         .onReceive(refreshTimer) { event in
            // Update estimations on timer call
            self.getEstimationsFromController()
         }
   }


   var body: some View {
      VStack(spacing: 0) {
         // The header of the view is always visible
         fixedHeader
            .padding()
         // Estimations are visible only when the view is opened
         if (isOpen || !canToggle) {
            Divider()
            content
               .padding([.horizontal, .bottom])
               .padding(.top, 7)
         }
      }
      .background(
         canToggle
         ? (isOpen
            ? (colorScheme == .dark ? Color(.tertiarySystemBackground): Color(.systemBackground))
            : (colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)))
         : Color.clear
      )
      .cornerRadius(10)
      .onTapGesture {
         if (canToggle) {
            // If the view can be opened and closed
            self.isOpen = !self.isOpen
            TapticEngine.impact.feedback(.medium)
         }
      }
   }

}
