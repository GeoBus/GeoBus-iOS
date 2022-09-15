//
//  RouteDetailsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsView: View {

   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController


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
            Text("Service may be unavailable.")
               .font(Font.system(size: 12, weight: .medium, design: .default))
               .foregroundColor(Color(.tertiaryLabel))
            Text("Click here to retry ↺")
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
            LiveIcon()
            Text(vehiclesController.vehicles.count == 1 ? "1 active vehicle" : "\(vehiclesController.vehicles.count) active vehicles")
               .font(Font.system(size: 11, weight: .medium, design: .default) )
               .lineLimit(1)
               .foregroundColor(Color(.secondaryLabel))
            Spacer()
         }
         Text(routesController.selectedVariant?.name ?? "-")
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
         if (appstate.current == .error) {
            connectionError
         } else if (routesController.selectedRoute != nil) {
            selectedRouteDetails
         } else {
            initScreen
         }
      }
   }

}
