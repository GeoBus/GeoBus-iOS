//
//  StopDetailsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/10/2022.
//

import SwiftUI


struct ConnectionSheetView: View {
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      ScrollView {
         StopDetailsView(
            canToggle: false,
            stopId: carrisNetworkController.activeConnection?.stop.id ?? 0,
            name: carrisNetworkController.activeConnection?.stop.name ?? "-",
            orderInRoute: carrisNetworkController.activeConnection?.orderInRoute,
            direction: carrisNetworkController.activeConnection?.direction
         )
      }
   }
   
}


struct StopSheetView: View {
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      ScrollView {
         StopDetailsView(
            canToggle: false,
            stopId: carrisNetworkController.activeStop?.id ?? 0,
            name: carrisNetworkController.activeStop?.name ?? "-",
            orderInRoute: nil,
            direction: nil
         )
      }
   }
   
}




struct StopDetailsHeader: View {
   
   let stopId: Int
   let name: String
   let orderInRoute: Int?
   let direction: CarrisNetworkModel.Direction?
   
   var body: some View {
      HStack(spacing: 15) {
         StopIcon(orderInRoute: self.orderInRoute, direction: self.direction)
         Text(name)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)
         Spacer()
         Text(String(self.stopId))
            .font(Font.system(size: 12, weight: .medium, design: .default) )
            .foregroundColor(Color(.secondaryLabel))
            .padding(.vertical, 2)
            .padding(.horizontal, 7)
            .background(Color(.secondarySystemFill))
            .cornerRadius(10)
      }
      .padding()
   }
   
}




struct StopDetailsView: View {
   
   let canToggle: Bool
   
   let stopId: Int
   let name: String
   let orderInRoute: Int?
   let direction: CarrisNetworkModel.Direction?
   
   @State private var isOpen = false
   
   @Environment(\.colorScheme) var colorScheme: ColorScheme
   
   
   var body: some View {
      VStack(alignment: .leading, spacing: 0) {
         Button(action: {
            if (canToggle) {
               self.isOpen = !self.isOpen
               TapticEngine.impact.feedback(.medium)
            }
         }, label: {
            StopDetailsHeader(stopId: self.stopId, name: self.name, orderInRoute: self.orderInRoute, direction: self.direction)
         })
         if (isOpen || !canToggle) {
            Divider()
            EstimationsContainer(stopId: self.stopId)
               .padding()
         }
      }
      .background(
         canToggle
         ? (isOpen
            ? (colorScheme == .dark ? Color(.tertiarySystemBackground): Color(.systemBackground))
            : (colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)))
         : Color.clear
      )
      .cornerRadius(10)
   }
   
}

