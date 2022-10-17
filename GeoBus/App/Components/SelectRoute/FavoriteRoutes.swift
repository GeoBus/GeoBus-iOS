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

   @EnvironmentObject var carrisNetworkController: CarrisNetworkController

   @Binding var showSelectRouteSheet: Bool

   @State var routes: [CarrisNetworkModel.Route] = []
   

   var body: some View {

      VStack(spacing: 0) {
         
         Text("Favorites")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(.label))
            .padding()

         Divider()

         if (carrisNetworkController.favorites_routes.count > 0) {
            
            LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 100), spacing: 15)], spacing: 15) {
               ForEach(routes) { route in
                  Button(action: {
                     self.carrisNetworkController.select(route: route.number)
                     Analytics.shared.capture(event: .Routes_Select_FromFavorites, properties: ["routeNumber": route.number])
                     self.showSelectRouteSheet = false
                  }){
                     RouteBadgeSquare(routeNumber: route.number)
                  }
               }
            }
            .padding(20)
            .onAppear(perform: {
               // Filter routes belonging to the provided Kind
               self.routes = self.carrisNetworkController.favorites_routes
               // Sort those routes by their route number
               self.routes.sort(by: { $0.number < $1.number })
            })

         } else {

            Text("You have no favorite routes.")
               .padding(20)

         }

      }
      .background(Color("BackgroundSecondary"))
      .cornerRadius(15)
   }
}
