//
//  SetOfRoutes.swift
//  GeoBus
//
//  Created by João on 27/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import Grid

struct SetOfRoutes: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   var title: Text
   var kind: RouteKind

   @Binding var showSelectRouteSheet: Bool

   @EnvironmentObject var routesController: RoutesController
   @State private var routes: [RouteFinal] = []


   var body: some View {

      VStack {

         title
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(.label))
            .padding(.top, 20)

         HorizontalLine()

         Grid(self.routes) { route in

            Button(action: {
               self.routesController.select(route: route)
               self.showSelectRouteSheet = false
            }){
               RouteButton(route: route, dimensions: 60)
            }

         }
         .gridStyle(ModularGridStyle(columns: .min(70), rows: .fixed(70)))
         .padding(.top, 5)
         .padding(.bottom)
         .padding(.horizontal)
         .onAppear(perform: {
            self.routes = self.routesController.allRoutes.filter({
               if case self.kind = $0.kind { return true }; return false
            })
         })

      }
      .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
      .cornerRadius(15)
      .padding()

   }

}
