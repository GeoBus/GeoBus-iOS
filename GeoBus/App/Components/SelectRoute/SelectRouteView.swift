//
//  SelectRouteView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteView: View {

   @EnvironmentObject var routesController: RoutesController
   

   var body: some View {

      ZStack {

         if (Appstate.shared.global == .loading) {
            LoadingView()

         } else if (Appstate.shared.global == .error) {
            RoundedRectangle(cornerRadius: 10)
               .fill(Color(.systemRed).opacity(0.5))
            Image(systemName: "wifi.exclamationmark")
               .font(.title)
               .foregroundColor(Color(.white))

         } else {

            if (routesController.selectedRoute != nil) {
               RouteBadgeSquare(routeNumber: routesController.selectedRoute!.number)
               
            } else {
               RoundedRectangle(cornerRadius: 10)
                  .fill(Color(.systemGray4))
               Image(systemName: "plus")
                  .font(.title)
                  .foregroundColor(Color(.white))

            }

         }

      }
      .aspectRatio(1, contentMode: .fit)
      
   }
}
