//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SearchStopInput: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @Binding var showSheet: Bool

   @State var showErrorLabel: Bool = false

   @State var stopPublicId = ""

   var body: some View {
      VStack {
         HStack {
            TextField("_ _ _", text: self.$stopPublicId)
               .font(.system(size: 30, weight: .bold, design: .default))
               .multilineTextAlignment(.center)
               .padding()
               .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.secondarySystemFill))
               .cornerRadius(10)
               .frame(width: 150)

            Button(action: {
               let success = self.stopsController.select(stop: self.stopPublicId.uppercased(), returnResult: true)
               if success {
                  self.showSheet = false
                  routesController.deselect()
                  vehiclesController.deselect()
               } else {
                  self.showErrorLabel = true
               }
            }) {
               Text("Locate")
                  .font(.system(size: 40, weight: .bold, design: .default))
                  .foregroundColor(stopPublicId.count > 2 ? Color(.white) : Color(.secondaryLabel))
            }
            .disabled(stopPublicId.count == 0)
            .frame(maxWidth: .infinity)
            .padding()
            .background(stopPublicId.count > 2 ? Color(.systemBlue) : (colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)) )
            .cornerRadius(10)
         }

         if (showErrorLabel && stopPublicId.count > 0) {
            Text("The stop you entered is not available.")
               .font(.body)
               .fontWeight(.bold)
               .multilineTextAlignment(.center)
               .foregroundColor(Color(.systemOrange))
               .padding()
         }

         VStack {
            Text("Choose a Stop Number")
               .font(.body)
               .multilineTextAlignment(.center)
            Text("(ex: 10706)")
               .font(.footnote)
               .multilineTextAlignment(.center)
         }
         .padding()

      }
   }
}
