//
//  SelectedRouteDisplay.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteButton: View {

   @ObservedObject var vehiclesStorage: VehiclesStorage

   @EnvironmentObject var routesController: RoutesController
   

   var body: some View {

      ZStack {

         if vehiclesStorage.state == .loading {

            LoadingView()

         } else if vehiclesStorage.state == .error {

            RoundedRectangle(cornerRadius: 10)
               .fill(Color(.systemRed).opacity(0.5))
            Image(systemName: "wifi.exclamationmark")
               .font(.title)
               .foregroundColor(Color(.white))

         } else {

            if (routesController.selectedRoute != nil) {

               RouteButton(route: routesController.selectedRoute!, dimensions: 80)

            } else {

               RoundedRectangle(cornerRadius: 10)
                  .fill(Color(.systemGray4))
               Image(systemName: "plus")
                  .font(.title)
                  .foregroundColor(Color(.white))

            }

         }

      }
      .frame(width: 80, height: 80)
      .padding(.leading, 15)
      .padding(.trailing, 10)
      
   }
}
