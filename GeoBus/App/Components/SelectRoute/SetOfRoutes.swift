//
//  SetOfRoutes.swift
//  GeoBus
//
//  Created by João on 27/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SetOfRoutes: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   var title: Text
   var kind: Kind

   @Binding var showSelectRouteSheet: Bool
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController
   @State private var routes: [Route] = []

   var body: some View {

      VStack(spacing: 0) {

         title
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(.label))
            .padding()

         Divider()

         LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 100), spacing: 15)], spacing: 15) {
            ForEach(routes) { route in
               Button(action: {
                  _ = self.routesController.select(byRouteNumber: route.number)
                  self.vehiclesController.set(route: route.number)
                  self.showSelectRouteSheet = false
               }){
                  RouteBadgeSquare(routeNumber: route.number)
               }
            }
         }
         .padding()
         .onAppear(perform: {
            // Filter routes belonging to the provided Kind
            self.routes = self.routesController.allRoutes.filter({
               if case self.kind = $0.kind { return true }; return false
            })
            // Sort those routes by their route number
            self.routes.sort(by: { $0.number < $1.number })
         })

      }
      .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
      .cornerRadius(15)
      .padding()

   }

}
