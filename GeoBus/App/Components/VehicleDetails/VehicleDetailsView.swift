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
   
   let vehicle: CarrisNetworkModel.Vehicle
   
   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   let refreshTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State var lastSeenTime: String = "-"
   
   
//   init(vehicle: CarrisNetworkModel.Vehicle) {
//      self.vehicle = carrisNetworkController.find(vehicle: vehicle.id)
//   }
   
   
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
         VehicleDestination(routeNumber: vehicle.routeNumber ?? "-", destination: vehicle.lastStopOnVoyageName ?? "-")
         Spacer()
         VehicleIdentifier(busNumber: vehicle.id, vehiclePlate: vehicle.vehiclePlate)
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
                  self.lastSeenTime = Helpers.getTimeString(for: vehicle.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
               .onReceive(lastSeenTimeTimer) { event in
                  self.lastSeenTime = Helpers.getTimeString(for: vehicle.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
            Spacer()
         }
      }
   }
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         if (appstate.vehicles == .loading) {
            loadingScreen
               .padding()
         } else if (appstate.vehicles == .error) {
            errorScreen
               .padding()
         } else {
            vehicleDetailsHeader
               .padding()
            Divider()
            vehicleDetailsScreen
               .padding()
         }
      }
      .onAppear() {
         carrisNetworkController.getAdditionalDetailsFor(vehicle: self.vehicle.id)
      }
      .onReceive(refreshTimer) { event in
         carrisNetworkController.getAdditionalDetailsFor(vehicle: self.vehicle.id)
      }
      
   }
   
}
