//
//  SetOfRoutes.swift
//  GeoBus
//
//  Created by João on 27/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SetOfRoutes: View {

   @EnvironmentObject var carrisNetworkController: CarrisNetworkController

   var title: Text
   var kind: Kind

   @Binding var showSheet: Bool
   @State private var routes: [Route_NEW] = []

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
                  self.carrisNetworkController.select(route: route.number)
                  Analytics.shared.capture(event: .Routes_Select_FromList, properties: ["routeNumber": route.number])
                  self.showSheet = false
               }){
                  RouteBadgeSquare(routeNumber: route.number)
               }
            }
         }
         .padding(20)
         .onAppear(perform: {
            // Filter routes belonging to the provided Kind
            self.routes = self.carrisNetworkController.allRoutes.filter({
               if case self.kind = $0.kind { return true }; return false
            })
            // Sort those routes by their route number
            self.routes.sort(by: { $0.number < $1.number })
         })

      }
      .background(Color("BackgroundSecondary"))
      .cornerRadius(15)

   }

}
