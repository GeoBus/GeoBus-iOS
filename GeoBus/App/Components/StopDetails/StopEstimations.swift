//
//  StopEstimations.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopEstimations: View {

   @EnvironmentObject var appstate: Appstate

   let estimations: [Estimation]?
   

   var fixedInfo: some View {
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
         Spacer()
      }
   }

   var estimationsList: some View {
      VStack(spacing: 12) {
         ForEach(estimations!) { estimation in
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

   var errorScreen: some View {
      Text("Carris API is unavailable.")
         .font(Font.system(size: 13, weight: .medium, design: .default) )
         .foregroundColor(Color(.secondaryLabel))
   }


   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
         fixedInfo
         if (appstate.estimations == .idle && estimations != nil) {
            if (estimations!.count > 0) {
               estimationsList
            } else {
               noResultsScreen
            }
         } else if (appstate.estimations == .loading) {
            loadingScreen
         } else {
            errorScreen
         }
      }
   }

}
