//
//  StopEstimations.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct EstimationsContainer: View {
   
   let stopId: Int
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   @State var estimations: [CarrisNetworkModel.Estimation]?
   
   let refreshTimer = Timer.publish(every: 30 /* seconds */, on: .main, in: .common).autoconnect()
   
   
   func getEstimationsFromController(_ value: Any?) {
      Task {
         self.estimations = await carrisNetworkController.getEstimation(for: self.stopId)
      }
   }
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
         EstimationsHeader()
         EstimationsList(estimations: self.estimations)
            .onAppear() { self.getEstimationsFromController(nil) }
            .onReceive(refreshTimer, perform: self.getEstimationsFromController(_:))
            .onChange(of: carrisNetworkController.communityDataProviderStatus) { value in
               self.estimations = nil
               self.getEstimationsFromController(nil)
            }
         CommunityProviderToggle()
            .padding(.vertical)
         Disclaimer()
            .padding(.vertical)
      }
   }
   
   
   
}




struct EstimationsHeader: View {
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      HStack {
         Text("Next on this stop:")
            .font(Font.system(size: 10, weight: .bold, design: .default) )
            .textCase(.uppercase)
            .foregroundColor(Color(.tertiaryLabel))
         Spacer()
         if (carrisNetworkController.communityDataProviderStatus) {
            PulseLabel(accent: Color(.systemTeal), label: Text("Community"))
         } else {
            PulseLabel(accent: Color(.systemOrange), label: Text("Estimated"))
         }
      }
   }
   
}







struct EstimationsList: View {
   
   let estimations: [CarrisNetworkModel.Estimation]?
   
   
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
   
   
   var noResultsScreen: some View {
      Text("No estimations available for this stop.")
         .font(Font.system(size: 13, weight: .medium, design: .default) )
         .foregroundColor(Color(.secondaryLabel))
   }
   
   
   var estimationsList: some View {
      VStack(spacing: 12) {
         ForEach(estimations!) { estimation in
            EstimationContainer(estimation: estimation)
         }
      }
   }
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
         if (estimations != nil) {
            if (estimations!.count > 0) {
               estimationsList
            } else {
               noResultsScreen
            }
         } else {
            loadingScreen
         }
      }
   }
   
}






struct EstimationContainer: View {
   
   let estimation: CarrisNetworkModel.Estimation
   
   @ObservedObject private var sheetController = SheetController.shared
   @ObservedObject private var mapController = MapController.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var estimationLine: some View {
      HStack(spacing: 4) {
         RouteBadgePill(routeNumber: estimation.routeNumber)
         DestinationText(destination: estimation.destination)
         Spacer(minLength: 5)
         TimeLeft(time: estimation.eta)
      }
   }
   
   
   var body: some View {
      
      if (estimation.busNumber != nil) {
         Button(action: {
            carrisNetworkController.select(vehicle: estimation.busNumber)
            // mapController.moveMap(to:)
            sheetController.present(sheet: .VehicleDetails)
         }, label: {
            estimationLine
         })
      } else {
         estimationLine
      }
   }
}

