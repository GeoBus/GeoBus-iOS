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
   
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   @State var estimations: [CarrisNetworkModel.Estimation]?
   
   let refreshTimer = Timer.publish(every: 60 /* seconds */, on: .main, in: .common).autoconnect()
   
   
   func getEstimationsFromController() {
      Task {
         self.estimations = await carrisNetworkController.getEstimation(for: self.stopId)
      }
   }
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
         EstimationsHeader()
         EstimationsList(estimations: self.estimations)
            .onAppear(perform: self.getEstimationsFromController)
            .onReceive(refreshTimer) { event in
               self.getEstimationsFromController()
            }
         debug_providerToggle
            .padding(.vertical)
         Disclaimer()
            .padding(.vertical)
      }
   }
   
   
   
   // ! DEBUG
   var debug_providerToggle: some View {
      VStack {
         Toggle(isOn: $carrisNetworkController.communityDataProviderStatus) {
            HStack {
               Image(systemName: "staroflife.circle")
                  .renderingMode(.template)
                  .font(Font.system(size: 25))
                  .foregroundColor(.teal)
               Text("Community Data")
                  .font(Font.system(size: 18, weight: .bold))
                  .foregroundColor(.teal)
                  .padding(.leading, 5)
            }
         }
         .padding()
         .frame(maxWidth: .infinity)
         .tint(.teal)
         .background(.teal.opacity(0.05))
         .cornerRadius(10)
         .onChange(of: carrisNetworkController.communityDataProviderStatus) { value in
            carrisNetworkController.toggleCommunityDataProviderTo(to: value)
            self.estimations = nil
            self.getEstimationsFromController()
         }
         Button(action: {
            self.estimations = nil
            self.getEstimationsFromController()
         }, label: {
            Text("Reload Estimate")
               .font(Font.system(size: 15, weight: .bold, design: .default) )
               .foregroundColor(Color(.white))
               .padding(5)
               .frame(maxWidth: .infinity)
               .background(Color(.systemBlue))
               .cornerRadius(10)
         })
      }
   }
   
   
   
}




struct EstimationsHeader: View {
   
   var body: some View {
      HStack {
         Text("Next on this stop:")
            .font(Font.system(size: 10, weight: .bold, design: .default) )
            .textCase(.uppercase)
            .foregroundColor(Color(.tertiaryLabel))
         Spacer()
         PulseLabel(accent: .orange, label: Text("Estimated"))
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
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var mapController = MapController.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      Button(action: {
         carrisNetworkController.select(vehicle: estimation.busNumber)
//         mapController.moveMap(to:)
         appstate.present(sheet: .carris_vehicleDetails)
      }, label: {
         HStack(spacing: 4) {
            RouteBadgePill(routeNumber: estimation.routeNumber)
            DestinationText(destination: estimation.destination)
            Spacer(minLength: 5)
            TimeLeft(time: estimation.eta)
         }
      })
   }
}

