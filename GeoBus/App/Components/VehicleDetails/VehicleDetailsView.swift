//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct VehicleDetailsView: View {

   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var vehiclesController: VehiclesController

   let refreshTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()

   let busNumber: String
   let routeNumber: String
   let lastGpsTime: String

   @State var vehicleDetails: VehicleDetails? = nil
   @State var lastSeenTime: String = "-"


   func getVehicleDetailsFromController() {
      Task {
         self.vehicleDetails = await vehiclesController.fetchVehicleDetailsFromAPI(for: self.busNumber)
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

   var errorScreen: some View {
      Text("Carris API is unavailable.")
         .font(Font.system(size: 13, weight: .medium, design: .default) )
         .foregroundColor(Color(.secondaryLabel))
   }

   var vehicleDetailsHeader: some View {
      HStack(spacing: 15) {
         HStack {
            RouteBadgePill(routeNumber: routeNumber)
            Text("to")
               .font(.footnote)
               .foregroundColor(Color(.tertiaryLabel))
            Text(vehicleDetails!.lastStopOnVoyageName)
               .font(.body)
               .fontWeight(.medium)
               .foregroundColor(Color(.label))
         }
         Spacer()
         VehicleIdentifier(busNumber: busNumber, vehiclePlate: vehicleDetails!.vehiclePlate)
      }
   }


   var vehicleDetailsScreen: some View {
      VStack(alignment: .leading) {
         HStack(alignment: .center, spacing: 5) {
            Image(systemName: "antenna.radiowaves.left.and.right")
               .font(.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
            Text("GPS updated \(lastSeenTime) ago")
               .font(.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
               .onAppear() {
                  self.lastSeenTime = Globals().getLastSeenTimeString(for: lastGpsTime)
               }
               .onReceive(lastSeenTimeTimer) { event in
                  self.lastSeenTime = Globals().getLastSeenTimeString(for: lastGpsTime)
               }
            Spacer()
         }
      }
   }


   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         if (vehicleDetails != nil) {
            vehicleDetailsHeader
               .padding()
            Divider()
            vehicleDetailsScreen
               .padding()
         } else if (appstate.vehicles == .loading) {
            loadingScreen
               .padding()
         } else {
            errorScreen
               .padding()
         }
      }
      .onAppear() {
         // Get vehicle details when view appears
         self.getVehicleDetailsFromController()
      }
      .onReceive(refreshTimer) { event in
         // Update details on timer call
         self.getVehicleDetailsFromController()
      }

   }

}
