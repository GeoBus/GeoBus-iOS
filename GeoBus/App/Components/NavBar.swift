//
//  NavBar.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//

import SwiftUI
import Combine

struct NavBar: View {

   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var routesController: RoutesController

   @State var showSelectRouteSheet: Bool = false
   @State var showRouteDetailsSheet: Bool = false


   // This is the route button, the left side of the NavBar.
   // Depending on the state, the button conveys different information.
   var routeSelector: some View {
      Button(action: {
         self.showSelectRouteSheet = true
      }) {
         SelectRouteView()
      }
      .sheet(isPresented: $showSelectRouteSheet) {
         SelectRouteSheet(isPresentingSheet: self.$showSelectRouteSheet)
      }
   }

   // This is the route details panel, the right side of the NavBar.
   // If a route is selected, it's details appear here. If no route is selected,
   // then it acts as button to choose a route.
   var routeDetails: some View {
      Button(action: {
         if (routesController.selectedRoute != nil) {
            self.showRouteDetailsSheet = true
         } else {
            self.showSelectRouteSheet = true
         }
      }) {
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
      VStack(alignment: .leading, spacing: 0) {
         HStack(spacing: 0) {
            routeSelector
               .padding()
            Divider()
            routeDetails
               .padding()
         }
         Divider()
      }
      .frame(height: 120)
      .background(Color("BackgroundSecondary"))
   }

}
