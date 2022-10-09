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
            StopEstimationRow(estimation: estimation)
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
         } else if (appstate.estimations == .error) {
            errorScreen
         } else {
            loadingScreen
         }
      }
   }
   
}




struct StopEstimationRow: View {
   
   let estimation: Estimation
   let estimatedTimeOfArrivalTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State var estimatedTimeOfArrival: String = "..."
   
   var body: some View {
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
         Text(self.estimatedTimeOfArrival)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .onAppear() {
               self.estimatedTimeOfArrival = Globals().getTimeString(for: estimation.eta, in: .future, style: .short, units: [.hour, .minute, .second])
            }
            .onReceive(estimatedTimeOfArrivalTimer) { event in
               self.estimatedTimeOfArrival = Globals().getTimeString(for: estimation.eta, in: .future, style: .short, units: [.hour, .minute, .second])
            }
      }
   }
   
}
