//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//
import SwiftUI
import Combine


struct CarrisVehicleSheetView: View {
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      if (carrisNetworkController.activeVehicle != nil && carrisNetworkController.activeVehicle!.hasLoadedCarrisDetails) {
         Text("Details")
      } else if (appstate.vehicles == .loading) {
         Spinner(size: 30)
      } else {
         Text("Error")
      }
   }
   
}





struct VehicleDetailsView: View {
   
   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State var lastSeenTime: String = "-"
   
   
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
         VehicleDestination(routeNumber: carrisNetworkController.activeVehicle?.routeNumber ?? "-", destination: carrisNetworkController.activeVehicle?.lastStopOnVoyageName ?? "-")
         Spacer()
         VehicleIdentifier(busNumber: carrisNetworkController.activeVehicle?.id ?? -1, vehiclePlate: carrisNetworkController.activeVehicle?.vehiclePlate)
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
                  self.lastSeenTime = Helpers.getTimeString(for: carrisNetworkController.activeVehicle?.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
               .onReceive(lastSeenTimeTimer) { event in
                  self.lastSeenTime = Helpers.getTimeString(for: carrisNetworkController.activeVehicle?.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
            Spacer()
         }
         VehicleRouteContainer(vehicle: carrisNetworkController.activeVehicle)
      }
   }
   
   
   var body: some View {
      ScrollView {
         VStack(alignment: .leading) {
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
            Disclaimer()
            Spacer()
         }
      }
   }
   
}





struct VehicleRouteContainer: View {
   
   let vehicle: CarrisNetworkModel.Vehicle?
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         if (vehicle?.routeEstimates != nil) {
            ForEach(Array(vehicle!.routeEstimates!.enumerated()), id: \.offset) { index, element in
               VStack(alignment: .leading, spacing: 0) {
                  if (index > 0) {
                     Rectangle()
                        .frame(width: 5, height: 25)
                        .foregroundColor(element.hasArrived ?? false ? .green : .blue)
                        .padding(.horizontal, 10)
                  }
                  Button(action: {
                     _ = carrisNetworkController.select(stop: element.stopId)
                     appstate.present(sheet: .carris_stopDetails)
                  }, label: {
                     HStack(alignment: .center, spacing: 10) {
                        StopIcon(orderInRoute: index)
                        Text(String(element.stopId))
                        Spacer()
                        if (element.hasArrived ?? false) {
                           Text("já passou")
                        } else {
                           TimeLeft(time: element.eta)
                        }
                     }
                  })
               }
            }
         } else {
            Text("Is nil, loading?")
         }
      }
   }
   
   
   
}
