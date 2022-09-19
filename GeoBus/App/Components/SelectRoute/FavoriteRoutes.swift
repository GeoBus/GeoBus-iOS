//
//  FavoriteRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct FavoriteRoutes: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @Binding var showSelectRouteSheet: Bool

   @State var routes: [Route] = []
   

   var body: some View {

      VStack(spacing: 0) {
         
         Text("Favorites")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(.label))
            .padding()

         Divider()

         if (routesController.favorites.count > 0) {
            
            LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 100), spacing: 15)], spacing: 15) {
               ForEach(routes) { route in
                  Button(action: {
                     self.stopsController.deselect()
                     self.routesController.select(route: route.number)
                     self.vehiclesController.set(route: route.number)
                     self.appstate.capture(event: "Routes-Select-FromFavorites", properties: ["routeNumber": route.number])
                     self.showSelectRouteSheet = false
                  }){
                     RouteBadgeSquare(routeNumber: route.number)
                  }
               }
            }
            .padding(20)
            .onAppear(perform: {
               // Filter routes belonging to the provided Kind
               self.routes = self.routesController.favorites
               // Sort those routes by their route number
               self.routes.sort(by: { $0.number < $1.number })
            })

         } else {

            Text("You have no favorite routes.")
               .padding(20)

         }

      }
      .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
      .cornerRadius(15)
   }
}
