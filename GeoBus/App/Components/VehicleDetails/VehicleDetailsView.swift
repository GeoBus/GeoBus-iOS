//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//
import SwiftUI
import Combine
import MapKit


struct CarrisVehicleSheetView: View {
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body: some View {
      VStack(spacing: 0) {
         CarrisVehicleSheetHeader(vehicle: carrisNetworkController.activeVehicle)
         ScrollView {
            VStack(alignment: .leading, spacing: 15) {
               if (appstate.carris_vehicleDetails == .error) {
                  SheetErrorScreen()
               } else {
                  HStack(spacing: 15) {
                     CarrisVehicleLastSeenTime(vehicle: carrisNetworkController.activeVehicle)
//                     CarrisVehicleToggleFollowOnMap()
                  }
               }
               CarrisVehicleRouteSummary(vehicle: carrisNetworkController.activeVehicle)
               Disclaimer()
            }
            .padding()
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
         self.lastSeenTime = Helpers.getTimeString(for: vehicle!.lastGpsTime!, in: .past, style: .short, units: [.hour, .minute, .second])
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




struct CarrisVehicleToggleFollowOnMap: View {
   
   private let storageKeyForShouldFollowOnMap: String = "ui_shouldFollowOnMap"
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var mapController = MapController.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   @State private var shouldFollowOnMap: Bool
   
   
   init() {
      self.shouldFollowOnMap = UserDefaults.standard.bool(forKey: storageKeyForShouldFollowOnMap)
   }
   
   
   func centerMapOnActiveVehicle() {
      if (shouldFollowOnMap && carrisNetworkController.activeVehicle != nil) {
         mapController.moveMap(to: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: carrisNetworkController.activeVehicle?.lat ?? 0, longitude: carrisNetworkController.activeVehicle?.lng ?? 0),
            latitudinalMeters: CLLocationDistance(1500), longitudinalMeters: CLLocationDistance(1500)
         ))
      }
   }
   
   var body: some View {
      Button(action: {
         TapticEngine.impact.feedback(.medium)
         self.shouldFollowOnMap = !shouldFollowOnMap
         UserDefaults.standard.set(shouldFollowOnMap, forKey: storageKeyForShouldFollowOnMap)
         self.centerMapOnActiveVehicle()
      }, label: {
         VStack {
            Image(systemName: shouldFollowOnMap ? "location.circle.fill" : "location.slash.circle")
               .font(.system(size: 20, weight: .medium))
         }
         .padding()
         .foregroundColor(shouldFollowOnMap ? .white : Color(.systemBlue))
         .background(shouldFollowOnMap ? Color(.systemBlue) : Color(.secondaryLabel).opacity(0.1))
         .cornerRadius(10)
         .onAppear(perform: centerMapOnActiveVehicle)
         .onChange(of: [carrisNetworkController.activeVehicle?.lat, carrisNetworkController.activeVehicle?.lng]) { _ in
            centerMapOnActiveVehicle()
         }
      })
   }
   
   
   
}













































struct CarrisVehicleRouteSummary: View {
   
   let vehicle: CarrisNetworkModel.Vehicle?
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   func findNextStop() -> Int? {
      if (vehicle?.routeOverview != nil) {
         
         if let previousStop = vehicle!.routeOverview!.lastIndex(where: {
            $0.hasArrived
         }) {
            if (previousStop + 1 < vehicle!.routeOverview!.count) {
               let nextStop = vehicle!.routeOverview![previousStop + 1]
               return nextStop.stopId
            }
         }
         
      }
      return nil
   }
   
   
   func findNextStopIndex() -> Int? {
      if (vehicle?.routeOverview != nil) {
         if let previousStop = vehicle!.routeOverview!.lastIndex(where: {
            $0.hasArrived
         }) {
            return previousStop + 1
         }
      }
      return nil
   }
   
   
   
   @State var nextStopIndex = 0
   @State var showAllStops = false
   
   
   
   
   var allStopsToggle: some View {
      VStack(alignment: .leading, spacing: 5) {
         HStack {
            Button(action: {
               TapticEngine.impact.feedback(.medium)
               self.showAllStops = !showAllStops
            }, label: {
               if (showAllStops) {
                  Image(systemName: "minus.square")
                     .frame(width: 25)
                  Text("Hide Previous Stops")
               } else {
                  Image(systemName: "plus.square")
                     .frame(width: 25)
                  Text("Show All Stops")
               }
            })
            Spacer()
            PulseLabel(accent: .teal, label: Text("Community"))
         }
         .font(Font.system(size: 15, weight: .medium))
         .foregroundColor(Color(.secondaryLabel))
      }
   }
   
   @State private var placeholderOpacity: Double = 1
   
   
   
   var content: some View {
      VStack(alignment: .leading, spacing: 0) {
         
         allStopsToggle
            .padding()
         
         Divider()
         
         VStack(alignment: .leading, spacing: 0) {
            ForEach(nextStopIndex..<vehicle!.routeOverview!.count, id: \.self) { index in
               VStack(alignment: .leading, spacing: 0) {
                  
                  CarrisVehicleRouteOverviewEstimationLine(
                     estimationLine: vehicle!.routeOverview![index],
                     nextStopId: findNextStop(),
                     thisStopIndex: index
                  )
                  .onAppear() {
                     if (!showAllStops) {
                        self.nextStopIndex = findNextStopIndex()! - 1
                        if (self.nextStopIndex < 0) { nextStopIndex = 0 }
                     } else {
                        self.nextStopIndex = 0
                     }
                  }
                  .onChange(of: vehicle?.routeOverview) { value in
                     if (!showAllStops) {
                        self.nextStopIndex = findNextStopIndex()! - 1
                        if (self.nextStopIndex < 0) { nextStopIndex = 0 }
                     } else {
                        self.nextStopIndex = 0
                     }
                  }
                  .onChange(of: showAllStops) { value in
                     if (!showAllStops) {
                        self.nextStopIndex = findNextStopIndex()! - 1
                        if (self.nextStopIndex < 0) { nextStopIndex = 0 }
                     } else {
                        self.nextStopIndex = 0
                     }
                  }
                  
                  
               }
            }
         }
         .padding(self.showAllStops || self.nextStopIndex < 1 ? .all : [.horizontal, .bottom])
         
      }
      .frame(maxWidth: .infinity)
      .background(Color(.secondaryLabel).opacity(0.1))
      .cornerRadius(10)
   }
   
   
   
   var placeholder: some View {
      VStack(spacing: 0) {
         ForEach(1...5, id: \.self) { index in
            HStack(alignment: .center) {
               Circle()
                  .frame(width: 25, height: 25)
               Rectangle()
                  .frame(width: 150, height: 15)
               Spacer()
               Circle()
                  .frame(width: 15, height: 15)
            }
            .font(Font.system(size: 15, weight: .medium))
            .padding()
            .foregroundColor(Color("PlaceholderShape"))
         }
      }
      .frame(maxWidth: .infinity)
      .background(Color("PlaceholderShape").opacity(0.3))
      .cornerRadius(10)
      .opacity(placeholderOpacity)
      .animatePlaceholder(binding: $placeholderOpacity)
   }
   
   
   
   var body: some View {
      if (vehicle?.routeOverview != nil && findNextStopIndex() != nil) {
         content
      } else {
         placeholder
      }
   }
   
   
}









struct CarrisVehicleRouteOverviewEstimationLine: View {
   
   let estimationLine: CarrisNetworkModel.Estimation
   let nextStopId: Int?
   let thisStopIndex: Int
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         
         if (estimationLine.hasArrived) {
            
            if (thisStopIndex > 0) {
               Rectangle()
                  .frame(width: 3, height: 30)
                  .foregroundColor(Color("StopMutedBackground"))
                  .padding(.horizontal, 11)
            }
            
            HStack(alignment: .center, spacing: 10) {
               StopIcon(style: .muted, orderInRoute: thisStopIndex+1)
               Text(carrisNetworkController.find(stop: estimationLine.stopId)?.name ?? "")
                  .font(Font.system(size: 17, weight: .medium))
                  .lineLimit(1)
                  .foregroundColor(estimationLine.hasArrived ? Color("StopMutedText") : .black)
               Spacer(minLength: 5)
               Image(systemName: "checkmark.circle")
                  .font(Font.system(size: 15, weight: .medium))
                  .foregroundColor(Color("StopMutedText"))
            }
            
         } else if (nextStopId == estimationLine.stopId) {
            
            VStack(alignment: .center, spacing: -2) {
               Rectangle()
                  .frame(width: 3, height: 30)
                  .foregroundColor(Color("StopMutedBackground"))
               Image(systemName: "arrowtriangle.down.circle.fill")
                  .font(Font.system(size: 15, weight: .medium))
                  .foregroundColor(Color(.systemBlue))
               Rectangle()
                  .frame(width: 5, height: 30)
                  .foregroundColor(Color(.systemBlue).opacity(0.5))
            }
            .frame(width: 25)
            
            HStack(alignment: .center, spacing: 10) {
               StopIcon(style: .circular, orderInRoute: thisStopIndex+1)
               Text(carrisNetworkController.find(stop: estimationLine.stopId)?.name ?? "")
                  .font(Font.system(size: 17, weight: .medium))
                  .lineLimit(1)
                  .foregroundColor(Color(.label))
               Spacer(minLength: 5)
               TimeLeft(time: estimationLine.eta, vehicleDidArrive: estimationLine.hasArrived, idleSeconds: estimationLine.idleSeconds)
            }
            
         } else {
            
            if (thisStopIndex > 0) {
               Rectangle()
                  .frame(width: 5, height: 30)
                  .foregroundColor(Color(.systemBlue))
                  .padding(.horizontal, 10)
            }
            
            HStack(alignment: .center, spacing: 10) {
               StopIcon(style: .circular, orderInRoute: thisStopIndex+1)
               Text(carrisNetworkController.find(stop: estimationLine.stopId)?.name ?? "")
                  .font(Font.system(size: 17, weight: .medium))
                  .lineLimit(1)
                  .foregroundColor(Color(.label))
               Spacer(minLength: 5)
               TimeLeft(time: estimationLine.eta, vehicleDidArrive: estimationLine.hasArrived, idleSeconds: estimationLine.idleSeconds)
            }
            
         }
         
         
      }
      
   }
   
   
}





















struct CarrisVehicleRouteOverview: View {
   
   let vehicle: CarrisNetworkModel.Vehicle?
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   func findNextStop() -> Int? {
      if (vehicle?.routeOverview != nil) {
         
         if let previousStop = vehicle!.routeOverview!.lastIndex(where: {
            $0.hasArrived
         }) {
            if (previousStop + 1 < vehicle!.routeOverview!.count) {
               let nextStop = vehicle!.routeOverview![previousStop + 1]
               return nextStop.stopId
            }
         }
         
      }
      return nil
   }
   
   
   func findNextStopIndex() -> Int? {
      if (vehicle?.routeOverview != nil) {
         if let previousStop = vehicle!.routeOverview!.lastIndex(where: {
            $0.hasArrived
         }) {
            return previousStop + 1
         }
      }
      return nil
   }
   
   
   
   
   
   var content: some View {
      ScrollViewReader { value in
         Button("Jump to #8") {
            if (findNextStopIndex() != nil) {
               value.scrollTo(findNextStopIndex())
            }
         }
         
         VStack(alignment: .leading, spacing: 0) {
            if (vehicle?.routeOverview != nil) {
               
               ForEach(Array(vehicle!.routeOverview!.enumerated()), id: \.offset) { index, element in
                  VStack(alignment: .leading, spacing: 0) {
                     
                     if (element.hasArrived) {
                        
                        if (index > 0) {
                           Rectangle()
                              .frame(width: 3, height: 30)
                              .foregroundColor(Color("StopMutedBackground"))
                              .padding(.horizontal, 11)
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                           StopIcon(style: .muted, orderInRoute: index+1)
                           Text(carrisNetworkController.find(stop: element.stopId)?.name ?? "")
                              .font(Font.system(size: 17, weight: .medium))
                              .lineLimit(1)
                              .foregroundColor(element.hasArrived ? Color("StopMutedText") : .black)
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
                           StopIcon(style: .standard, orderInRoute: index+1)
                           Text(carrisNetworkController.find(stop: element.stopId)?.name ?? "")
                              .font(Font.system(size: 17, weight: .medium))
                              .lineLimit(1)
                              .foregroundColor(Color(.label))
                           Spacer(minLength: 5)
                           TimeLeft(time: element.eta, vehicleDidArrive: element.hasArrived, idleSeconds: element.idleSeconds)
                        }
                        
                     } else {
                        
                        if (index > 0) {
                           Rectangle()
                              .frame(width: 5, height: 30)
                              .foregroundColor(Color(.systemBlue))
                              .padding(.horizontal, 10)
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                           StopIcon(style: .standard, orderInRoute: index+1)
                           Text(carrisNetworkController.find(stop: element.stopId)?.name ?? "")
                              .font(Font.system(size: 17, weight: .medium))
                              .lineLimit(1)
                              .foregroundColor(Color(.label))
                           Spacer(minLength: 5)
                           TimeLeft(time: element.eta, vehicleDidArrive: element.hasArrived, idleSeconds: element.idleSeconds)
                        }
                        
                     }
                     
                     
                  }
               }
               
               
               
            } else {
               Text("Is nil, loading?")
            }
            
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


