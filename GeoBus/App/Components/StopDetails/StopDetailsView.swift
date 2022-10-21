//
//  StopDetailsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/10/2022.
//

import SwiftUI

struct ConnectionDetailsView: View {
   
   let connection: CarrisNetworkModel.Connection
   
   @State private var viewSize = CGSize()
   
    var body: some View {
       VStack(alignment: .leading) {
          ConnectionDetailsView2(
            canToggle: false,
            publicId: connection.stop.id,
            name: connection.stop.name,
            orderInRoute: connection.orderInRoute,
            direction: connection.direction
          )
          .padding(.bottom, 20)
          Disclaimer()
             .padding(.horizontal)
             .padding(.bottom, 10)
       }
       .readSize { size in
          viewSize = size
       }
       .presentationDetents([.height(viewSize.height)])
    }
}


struct StopDetailsView: View {
   
   let stop: CarrisNetworkModel.Stop
   
   @State private var viewSize = CGSize()
   
   var body: some View {
      VStack(alignment: .leading) {
         ConnectionDetailsView2(
            canToggle: false,
            publicId: stop.id,
            name: stop.name,
            orderInRoute: 0,
            direction: .circular
         )
         .padding(.bottom, 20)
         Disclaimer()
            .padding(.horizontal)
            .padding(.bottom, 10)
      }
      .readSize { size in
         viewSize = size
      }
      .presentationDetents([.height(viewSize.height)])
   }
}







struct ConnectionDetailsView2: View {
   
   @Environment(\.colorScheme) var colorScheme: ColorScheme
   
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   let refreshTimer = Timer.publish(every: 60 /* seconds */, on: .main, in: .common).autoconnect()
   
   let canToggle: Bool
   let publicId: Int
   let name: String
   let orderInRoute: Int?
   let direction: CarrisNetworkModel.Direction?
   
   @State private var isOpen = false
   @State private var estimations: [CarrisNetworkModel.Estimation]? = nil
   
   
   func getEstimationsFromController() {
      Task {
         self.estimations = await carrisNetworkController.getEstimation(for: self.publicId)
      }
   }
   
   
   var fixedHeader: some View {
      HStack(spacing: 15) {
         StopIcon(orderInRoute: self.orderInRoute ?? 0, direction: self.direction ?? .circular)
         Text(name)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)
         Spacer()
         Text(String(publicId))
            .font(Font.system(size: 12, weight: .medium, design: .default) )
            .foregroundColor(Color(.secondaryLabel))
            .padding(.vertical, 2)
            .padding(.horizontal, 7)
            .background(colorScheme == .dark ? Color(.secondarySystemFill) : Color(.secondarySystemBackground))
            .cornerRadius(10)
      }
   }
   
   
   
   var content: some View {
      StopEstimations(estimations: self.estimations)
         .onAppear() {
            // Get estimations when view appears
            self.getEstimationsFromController()
         }
         .onReceive(refreshTimer) { event in
            // Update estimations on timer call
            self.getEstimationsFromController()
         }
   }
   
   
   var body: some View {
      VStack(spacing: 0) {
         // The header of the view is always visible
         fixedHeader
            .padding()
         // Estimations are visible only when the view is opened
         if (isOpen || !canToggle) {
            Divider()
            content
               .padding([.horizontal, .bottom])
               .padding(.top, 7)
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
      .onTapGesture {
         if (canToggle) {
            // If the view can be opened and closed
            self.isOpen = !self.isOpen
            TapticEngine.impact.feedback(.medium)
         }
      }
   }
   
}
