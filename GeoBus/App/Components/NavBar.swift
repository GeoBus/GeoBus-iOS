//
//  NavBar.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//

import SwiftUI
import Combine

struct NavBar: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var routesController: RoutesController

   @State var showSelectRouteSheet: Bool = false
   @State var showRouteDetailsSheet: Bool = false


   // This is the route button, the left side of the NavBar.
   // Depending on the state, the button conveys different information.
   var routeSelector: some View {
      Button(action: {
         // What happens when button is tapped
         if (routesController.allRoutes.count > 0) {
            self.showSelectRouteSheet = true
         }
      }) {
         // What is shown as the button view
         SelectRouteView()
      }
      .sheet(isPresented: $showSelectRouteSheet) {
         SelectRouteSheet(showSelectRouteSheet: self.$showSelectRouteSheet)
      }
   }

   // This is the route details panel, the right side of the NavBar.
   // If a route is selected, it's details appear here. If no route is selected,
   // then it acts as button to choose a route.
   var routeDetails: some View {
      Button(action: {
         // What happens when button is tapped
         if (routesController.selectedRoute != nil) {
            self.showRouteDetailsSheet = true
         } else {
            if (routesController.allRoutes.count > 0) {
               self.showSelectRouteSheet = true
            }
         }
      }) {
         // What is shown as the button view
         RouteDetailsView()
      }
      .sheet(isPresented: $showRouteDetailsSheet) {
         RouteDetailsSheet(showRouteDetailsSheet: self.$showRouteDetailsSheet)
      }
   }

   // The composed final view for the NavBar.
   // It encompasses the route selector and the route details panel,
   // as well as the current app version.
   var body: some View {
      VStack(alignment: .leading) {
         HStack(spacing: 0) {
            routeSelector
               .padding()
            Divider()
            routeDetails
               .padding()
         }
      }
      .frame(height: 120)
      .background(colorScheme == .dark ? Color(.systemGray5) : Color(.white))
   }

}
