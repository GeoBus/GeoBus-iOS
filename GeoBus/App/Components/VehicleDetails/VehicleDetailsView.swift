//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine


struct VehicleInfoSheet: View {
   
   public let busNumber: Int
   
   @EnvironmentObject var vehiclesController: VehiclesController
   
   private let refreshTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   
   
   var body: some View {
      ScrollView {
         
         // SECTION 1
         VehicleInfoSheetHeader(vehicle: vehiclesController.getVehicle(by: busNumber))
         
         // SECTION 2
         VehicleInfoSheetCurrentRouteStatus(vehicle: vehiclesController.getVehicle(by: busNumber))
            .padding()
         
         Spacer()
         
         VehicleInfoSheetLastSeenTime(vehicle: vehiclesController.getVehicle(by: busNumber))
            .padding()
         
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.hidden)
      .onAppear() {
         self.vehiclesController.update(scope: .detail, for: self.busNumber)
         self.vehiclesController.update(scope: .community, for: self.busNumber)
      }
      .onReceive(refreshTimer) { event in
         self.vehiclesController.update(scope: .detail, for: self.busNumber)
         self.vehiclesController.update(scope: .community, for: self.busNumber)
      }
   }
   
}



struct VehicleInfoSheetHeader: View {
   
   public let vehicle: Vehicle?
   
   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         HStack(spacing: 10) {
            VehicleDestination(routeNumber: vehicle?.routeNumber ?? "-", destination: vehicle?.lastStopOnVoyageName ?? "-")
            Spacer()
            VehicleIdentifier(busNumber: vehicle?.busNumber ?? 0, vehiclePlate: vehicle?.vehiclePlate ?? "-")
         }
         .padding()
         Divider()
      }
   }
   
}



struct VehicleInfoSheetLastSeenTime: View {
   
   public let vehicle: Vehicle?
   
   private let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State private var lastSeenTime: String = "-"
   
   
   var body: some View {
      VStack(alignment: .leading) {
         HStack(alignment: .center, spacing: 5) {
            Image(systemName: "antenna.radiowaves.left.and.right")
               .font(.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
            Text("GPS updated \(lastSeenTime) ago")
               .font(.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
               .onAppear() {
                  self.lastSeenTime = Globals().getTimeString(for: vehicle?.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
               .onReceive(lastSeenTimeTimer) { event in
                  self.lastSeenTime = Globals().getTimeString(for: vehicle?.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
            Spacer()
         }
      }
   }
   
}




struct VehicleInfoSheetCurrentRouteStatus: View {
   
   public let vehicle: Vehicle?
   
   let times = [
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20",
      "2022-10-10T23:11:20"
   ]
   
   var body: some View {
      VStack(spacing: 0) {
         // ForEach(vehicle?.estimatedTimeofArrivalCorrected ?? [], id: \.self) { timeString in
         ForEach(self.times, id: \.self) { timeString in
            VehicleInfoSheetRouteStop(timeString: timeString)
         }
      }
   }
   
}




struct VehicleInfoSheetRouteStop: View {
   
   
   
   public let timeString: String
   
   var body: some View {
      HStack {
         VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 15) {
               StopIcon(orderInRoute: 3, direction: .ascending)
               Text("Teste")
                  .fontWeight(.medium)
                  .foregroundColor(Color(.label))
                  .multilineTextAlignment(.leading)
               Spacer()
//               Text("45678")
//                  .font(Font.system(size: 12, weight: .medium, design: .default) )
//                  .foregroundColor(Color(.secondaryLabel))
//                  .padding(.vertical, 2)
//                  .padding(.horizontal, 7)
//                  .cornerRadius(10)
               TimeLeft(time: timeString)
            }
            HStack(spacing: 15) {
               Rectangle()
                  .foregroundColor(Color("StopSelectedBackground"))
                  .frame(width: 5, height: 25)
                  .padding(.leading, 10)
               VStack {
                  Divider()
               }
            }
         }
         Spacer()
//         TimeLeft(time: timeString)
      }

   }
   
}








//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//











struct VehicleInfoSheetHeader2: View {
   
   public let vehicle: Vehicle?
   
   @EnvironmentObject var vehiclesController: VehiclesController
   
   private let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()

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
         VehicleDestination(routeNumber: vehicle?.routeNumber ?? "-", destination: vehicle?.lastStopOnVoyageName ?? "-")
         Spacer()
         VehicleIdentifier(busNumber: vehicle?.busNumber ?? 0, vehiclePlate: vehicle?.vehiclePlate ?? "-")
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
                  self.lastSeenTime = Globals().getTimeString(for: vehicle?.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
               .onReceive(lastSeenTimeTimer) { event in
                  self.lastSeenTime = Globals().getTimeString(for: vehicle?.lastGpsTime ?? "", in: .past, style: .full, units: [.hour, .minute, .second])
               }
            Spacer()
         }
      }
   }
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         if (vehicle != nil) {
            vehicleDetailsHeader
               .padding()
            Divider()
            vehicleDetailsScreen
               .padding()
         } else if (Appstate.shared.vehicles == .loading) {
            loadingScreen
               .padding()
         } else {
            errorScreen
               .padding()
         }
      }
      
   }
   
}




























struct VehicleDetailsView: View {
   
   @EnvironmentObject var vehiclesController: VehiclesController
   
   let vehicle: VehicleSummary
   
   @State private var viewSize = CGSize()
   
   var body: some View {
      VStack(alignment: .leading) {
         VehicleDetailsView2(
            busNumber: vehicle.busNumber,
            routeNumber: vehicle.routeNumber,
            lastGpsTime: vehicle.lastGpsTime
         )
         .padding(.bottom, 20)
         Disclaimer()
            .padding(.horizontal)
            .padding(.bottom, 10)
      }
      .readSize { size in
         viewSize = size
      }
      .presentationDetents([.height(viewSize.height), .large])
      
   }
   
}






struct VehicleDetailsView2: View {
   
   @EnvironmentObject var vehiclesController: VehiclesController
   
   let refreshTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   let busNumber: Int
   let routeNumber: String
   let lastGpsTime: String
   
   @State var vehicleDetails: VehicleDetails? = nil
   @State var lastSeenTime: String = "-"
   
   
   func getVehicleDetailsFromController() {
      Task {
         self.vehicleDetails = await vehiclesController.fetchVehicleDetailsFromCarrisAPI(for: self.busNumber)
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
                  self.lastSeenTime = Globals().getTimeString(for: lastGpsTime, in: .past, style: .full, units: [.hour, .minute, .second])
               }
               .onReceive(lastSeenTimeTimer) { event in
                  self.lastSeenTime = Globals().getTimeString(for: lastGpsTime, in: .past, style: .full, units: [.hour, .minute, .second])
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
         } else if (Appstate.shared.vehicles == .loading) {
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
