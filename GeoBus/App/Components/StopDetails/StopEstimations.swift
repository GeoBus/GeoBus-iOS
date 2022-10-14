//
//  StopEstimations.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopEstimations: View {
   
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
            HStack(spacing: 5) {
               VehicleDestination(routeNumber: estimation.routeNumber, destination: estimation.destination)
               Spacer()
               TimeLeft(time: estimation.eta)
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
         if (estimations != nil) {
            if (estimations!.count > 0) {
               estimationsList
            } else {
               noResultsScreen
            }
         } else if (Appstate.shared.estimations == .error) {
            errorScreen
         } else {
            loadingScreen
         }
      }
   }
   
}


