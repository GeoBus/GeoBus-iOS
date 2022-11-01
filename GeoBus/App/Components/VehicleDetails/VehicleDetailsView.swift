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
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body: some View {
      VStack(spacing: 0) {
         if (appstate.vehicles == .error) {
            SheetErrorScreen()
         } else {
            CarrisVehicleSheetHeader(vehicle: carrisNetworkController.activeVehicle)
            ScrollView {
               VStack(alignment: .leading, spacing: 15) {
                  CarrisVehicleLastSeenTime(vehicle: carrisNetworkController.activeVehicle)
                  if (carrisNetworkController.communityDataProviderStatus) {
                     // CarrisVehicleNextStop(vehicle: carrisNetworkController.activeVehicle)
                     CarrisVehicleRouteOverview(vehicle: carrisNetworkController.activeVehicle)
                     Disclaimer()
                  } else {
                     DataProvidersCard()
                  }
               }
               .padding()
            }
         }
      }
   }
   
}





struct CarrisVehicleSheetHeader: View {
   
   public let vehicle: CarrisNetworkModel.Vehicle?
   
   var body: some View {
      VStack(spacing: 0) {
         HStack(spacing: 4) {
            RouteBadgePill(routeNumber: vehicle?.routeNumber)
            DestinationText(destination: vehicle?.lastStopOnVoyageName)
            Spacer(minLength: 15)
            VehicleIdentifier(busNumber: vehicle?.id, vehiclePlate: vehicle?.vehiclePlate)
         }
         .padding()
         Divider()
      }
   }
   
}






struct CarrisVehicleLastSeenTime: View {
   
   public let vehicle: CarrisNetworkModel.Vehicle?
   
   private let lastSeenTimeTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State private var lastSeenTime: String? = nil
   
   
   func updateLastSeenTime(_ value: Any) {
      if (vehicle?.lastGpsTime != nil) {
         self.lastSeenTime = Helpers.getTimeString(for: vehicle!.lastGpsTime!, in: .past, style: .full, units: [.hour, .minute, .second])
      }
   }
   
   
   var body: some View {
      Chip(
         icon: Image(systemName: "antenna.radiowaves.left.and.right"),
         text: Text("GPS updated \(lastSeenTime ?? "-") ago."),
         color: Color(.secondaryLabel),
         showContent: lastSeenTime != nil
      )
      .onChange(of: vehicle, perform: updateLastSeenTime(_:))
      .onReceive(lastSeenTimeTimer, perform: updateLastSeenTime(_:))
   }
   
}







struct CarrisVehicleNextStop: View {
   
   let vehicle: CarrisNetworkModel.Vehicle?
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   @State var nextStopIndex: Int = 0
   
   
   func setNextStop(_ value: Any) {
      if (vehicle?.routeOverview != nil) {
         if let previousStop = vehicle!.routeOverview!.lastIndex(where: {
            $0.hasArrived ?? false
         }) {
            nextStopIndex = previousStop + 1
         } else {
            nextStopIndex = 10
         }
      }
   }
   
   
   var placeholder: some View {
      EmptyView()
   }
   
   
   
   var actualContent: some View {
      VStack(spacing: 0) {
         HStack {
            Text("Next stop:")
               .font(Font.system(size: 10, weight: .bold))
               .textCase(.uppercase)
               .foregroundColor(Color(.secondaryLabel))
            Spacer()
            PulseLabel(accent: .blue, label: Text("Community"))
         }
         .padding(.vertical, 10)
         .padding(.horizontal)
         Divider()
         Button(action: {
            _ = carrisNetworkController.select(stop: vehicle!.routeOverview![nextStopIndex].stopId)
            appstate.present(sheet: .carris_stopDetails)
         }, label: {
            HStack(alignment: .center, spacing: 10) {
               StopIcon(orderInRoute: nextStopIndex + 1, style: .standard)
               Text(carrisNetworkController.find(stop: (vehicle!.routeOverview![nextStopIndex].stopId))?.name ?? "")
                  .font(Font.system(size: 17, weight: .medium))
                  .lineLimit(1)
                  .foregroundColor(Color(.label))
               Spacer(minLength: 5)
               TimeLeft(time: vehicle?.routeOverview![nextStopIndex].eta)
            }
            .onChange(of: vehicle, perform: setNextStop(_:))
            .padding()
         })
      }
      .frame(maxWidth: .infinity)
      .background(Color(.systemBlue).opacity(0.05))
      .cornerRadius(10)
      .overlay(
         RoundedRectangle(cornerRadius: 10)
            .stroke(Color(.systemBlue).opacity(1), lineWidth: 2)
      )
   }
   
   
   var body: some View {
      if (vehicle?.routeOverview != nil) {
         if (nextStopIndex < vehicle!.routeOverview!.count && vehicle?.routeOverview?[nextStopIndex] != nil) {
            actualContent
         }
      } else {
         placeholder
      }
   }
   
   
}





















































struct CarrisVehicleRouteOverview: View {
   
   let vehicle: CarrisNetworkModel.Vehicle?
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   
   func findNextStop() -> Int? {
      if (vehicle?.routeOverview != nil) {
         
         if let previousStop = vehicle!.routeOverview!.lastIndex(where: {
            $0.hasArrived ?? false
         }) {
            if (previousStop + 1 < vehicle!.routeOverview!.count) {
               let nextStop = vehicle!.routeOverview![previousStop + 1]
               return nextStop.stopId
            }
         }
         
      }
      return nil
   }
   
   
   
   
   
   var content: some View {
      VStack(alignment: .leading, spacing: 0) {
         if (vehicle?.routeOverview != nil) {
            
            ForEach(Array(vehicle!.routeOverview!.enumerated()), id: \.offset) { index, element in
               VStack(alignment: .leading, spacing: 0) {
                  
                  if (element.hasArrived ?? false) {
                     
                     if (index > 0) {
                        Rectangle()
                           .frame(width: 3, height: 30)
                           .foregroundColor(Color("StopMutedBackground"))
                           .padding(.horizontal, 11)
                     }

                     HStack(alignment: .center, spacing: 10) {
                        StopIcon(orderInRoute: index+1, style: .muted)
                        Text(carrisNetworkController.find(stop: element.stopId)?.name ?? "")
                           .font(Font.system(size: 17, weight: .medium))
                           .lineLimit(1)
                           .foregroundColor(element.hasArrived ?? false ? Color("StopMutedText") : .black)
                        Spacer(minLength: 5)
                        Image(systemName: "checkmark.circle")
                           .font(Font.system(size: 15, weight: .medium))
                           .foregroundColor(Color("StopMutedText"))
                     }

                  } else if (findNextStop() == element.stopId) {
                     
                     VStack(spacing: 0) {
                        Rectangle()
                           .frame(width: 3, height: 30)
                           .foregroundColor(Color("StopMutedBackground"))
                           .padding(.horizontal, 11)
                        Image(systemName: "arrowtriangle.down.circle.fill")
                           .font(Font.system(size: 15, weight: .medium))
                           .foregroundColor(Color(.systemBlue))
                           .padding(.vertical, -2)
                        Rectangle()
                           .frame(width: 5, height: 30)
                           .foregroundColor(Color(.systemBlue))
                           .padding(.horizontal, 10)
                     }
                     
                     HStack(alignment: .center, spacing: 10) {
                        StopIcon(orderInRoute: index+1, style: .standard)
                        Text(carrisNetworkController.find(stop: element.stopId)?.name ?? "")
                           .font(Font.system(size: 17, weight: .medium))
                           .lineLimit(1)
                           .foregroundColor(Color(.label))
                        Spacer(minLength: 5)
                        TimeLeft(time: element.eta)
                     }
                     
                  } else {
                     
                     if (index > 0) {
                        Rectangle()
                           .frame(width: 5, height: 30)
                           .foregroundColor(Color(.systemBlue))
                           .padding(.horizontal, 10)
                     }

                     HStack(alignment: .center, spacing: 10) {
                        StopIcon(orderInRoute: index+1, style: .standard)
                        Text(carrisNetworkController.find(stop: element.stopId)?.name ?? "")
                           .font(Font.system(size: 17, weight: .medium))
                           .lineLimit(1)
                           .foregroundColor(Color(.label))
                        Spacer(minLength: 5)
                        TimeLeft(time: element.eta)
                     }

                  }
                  
                  
                  
               }
            }
            
            
         } else {
            Text("Is nil, loading?")
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color(.secondaryLabel).opacity(0.1))
      .cornerRadius(10)
   }
   
   
   
   var body: some View {
      content
   }
   
   
}


