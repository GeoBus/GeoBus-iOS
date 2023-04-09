//
//  RouteDetailsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsView: View {

   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared


   // Initial screen simply explaining how to select a route,
   // also with app version and build.
   var initScreen: some View {
      ZStack(alignment: .bottomTrailing) {
         VStack(alignment: .leading) {
            Spacer()
            HStack {
               Text("← Choose a Route")
                  .font(Font.system(size: 15, weight: .bold, design: .default))
                  .foregroundColor(Color(.secondaryLabel))
               Spacer()
            }
            Spacer()
         }
         AppVersion()
      }

   }


   // Display error message if app encountered an error.
   var connectionError: some View {
      HStack {
         VStack(alignment: .leading, spacing: 10) {
            Text("Connection Error")
               .font(Font.system(size: 15, weight: .bold, design: .default))
               .foregroundColor(Color(.systemRed))
            Text("Carris API is unavailable.")
               .font(Font.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
         }
         Spacer()
      }
   }

   var updatingRoutesScreen: some View {
      HStack {
         VStack(alignment: .leading, spacing: 5) {
            Text("Updating Routes...")
               .font(Font.system(size: 15, weight: .bold, design: .default))
               .padding(.bottom, 5)
            Text("Please wait a few seconds.")
               .font(Font.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
            Text("This will only happen once.")
               .font(Font.system(size: 12, weight: .bold, design: .default))
               .foregroundColor(Color(.secondaryLabel))
         }
         Spacer()
      }
   }

   // Display currently selected route details.
   var selectedRouteDetails: some View {
      VStack(alignment: .leading) {
         HStack {
            PulseLabel(accent: .green, label: Text("Live"))
            Text(carrisNetworkController.activeVehicles.count == 1 ? "1 active vehicle" : "\(carrisNetworkController.activeVehicles.count) active vehicles")
               .font(Font.system(size: 11, weight: .medium, design: .default) )
               .lineLimit(1)
               .foregroundColor(Color(.secondaryLabel))
            Spacer()
         }
         Text(carrisNetworkController.activeVariant?.name ?? "-")
            .font(.body)
            .fontWeight(.bold)
            .lineLimit(2)
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)
         Spacer()
      }
   }
   
   // The final view where screens are composed based on appstate
   var body: some View {
      VStack {
         if (appstate.routes == .loading && carrisNetworkController.allRoutes.count < 1) {
            updatingRoutesScreen
         } else if (appstate.global == .error) {
            connectionError
         } else if (carrisNetworkController.activeRoute != nil) {
            selectedRouteDetails
         } else {
            initScreen
         }
      }
   }

}
