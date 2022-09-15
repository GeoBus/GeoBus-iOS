//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectRouteInput: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @Binding var showSelectRouteSheet: Bool

   @State var showErrorLabel: Bool = false

   @State var routeNumber = ""

   var body: some View {
      VStack {
         HStack {
            TextField("_ _ _", text: self.$routeNumber)
               .font(.system(size: 40, weight: .bold, design: .default))
               .multilineTextAlignment(.center)
               .padding()
               .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
               .cornerRadius(10)
               .frame(width: 120)

            Button(action: {
               let success = self.routesController.select(route: self.routeNumber.uppercased(), returnResult: true)
               if success {
                  vehiclesController.set(route: self.routeNumber.uppercased())
                  self.showSelectRouteSheet = false
               } else {
                  self.showErrorLabel = true
               }
            }) {
               Text("Locate")
                  .font(.system(size: 40, weight: .bold, design: .default))
                  .foregroundColor(routeNumber.count > 2 ? Color(.white) : Color(.secondaryLabel))
            }
            .disabled(routeNumber.count == 0)
            .frame(maxWidth: .infinity)
            .padding()
            .background(routeNumber.count > 2 ? Color(.systemBlue) : (colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)) )
            .cornerRadius(10)
         }

         if (showErrorLabel && routeNumber.count > 0) {
            Text("The route you entered is not available.")
               .font(.body)
               .fontWeight(.bold)
               .multilineTextAlignment(.center)
               .foregroundColor(Color(.systemOrange))
               .padding()
         }

         VStack {
            Text("Choose a Route Number")
               .font(.body)
               .multilineTextAlignment(.center)
            Text("(ex: 28E or 758)")
               .font(.footnote)
               .multilineTextAlignment(.center)
         }
         .padding()

      }
   }
}
