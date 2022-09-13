//
//  StopEstimations.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopEstimations: View {

   @EnvironmentObject var estimationsController: EstimationsController

   let timer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()

   let publicId: String

   @State var isLoading: Bool = true
   @State var estimations: [Estimation] = []


   func getEstimationsFromController() {
      Task {
         self.estimations = await estimationsController.get(for: self.publicId)
         self.isLoading = false
      }
   }


   var staticHeader: some View {
      HStack {
         Text("Next on this stop:")
            .font(Font.system(size: 10, weight: .bold, design: .default) )
            .textCase(.uppercase)
            .foregroundColor(Color(.tertiaryLabel))
         Spacer()
         EstimatedIcon()
      }
   }

   var loadingScreen: some View {
      HStack(spacing: 3) {
         ProgressView()
            .scaleEffect(0.55)
         Text("Loading...")
            .font(Font.system(size: 13, weight: .medium, design: .default) )
            .foregroundColor(Color(.tertiaryLabel))
      }
   }

   var estimationsList: some View {
      VStack(spacing: 18) {
         ForEach(estimations) { estimation in
            HStack {
               RouteBadgePill(routeNumber: estimation.routeNumber)
               Text("to")
                  .font(.footnote)
                  .foregroundColor(Color(.tertiaryLabel))
               Text(estimation.destination)
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(Color(.label))
               Spacer()
               Text("in ±")
                  .font(.footnote)
                  .foregroundColor(Color(.tertiaryLabel))
               Text(estimation.timeLeft)
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(Color(.label))
            }
         }
      }
   }

   var noResultsScreen: some View {
      Text("No estimations available for this stop.")
         .font(Font.system(size: 13, weight: .medium, design: .default) )
         .foregroundColor(Color(.secondaryLabel))
   }


   var body: some View {
      VStack(alignment: .leading, spacing: 15) {
         staticHeader
         if (isLoading) {
            loadingScreen
         } else {
            if (estimations.count > 0) {
               estimationsList
            } else {
               noResultsScreen
            }
         }
      }
      .onAppear() {
         self.getEstimationsFromController()
      }
      .onReceive(timer) { event in
         self.getEstimationsFromController()
      }
   }

}
