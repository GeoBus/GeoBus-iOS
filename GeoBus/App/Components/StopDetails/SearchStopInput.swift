//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SearchStopInput: View {

   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @Binding var showSheet: Bool
   @FocusState private var stopIdInputIsFocused: Bool

   @State private var showErrorLabel: Bool = false

   @State private var stopPublicId = ""

   var body: some View {
      VStack {
         HStack {
            HStack(spacing: 15) {
               Text("C")
                  .font(.system(size: 40, weight: .bold, design: .default))
               TextField("_ _ _ _ _", text: self.$stopPublicId)
                  .keyboardType(.numberPad)
                  .font(.system(size: 40, weight: .bold, design: .default))
                  .multilineTextAlignment(.leading)
                  .focused($stopIdInputIsFocused)
                  .onAppear {
                     self.stopIdInputIsFocused = true
                  }
            }
            .padding()
            .padding(.horizontal, 5)
            .background(Color("BackgroundSecondary"))
            .cornerRadius(10)

            Button(action: {
               let success = self.stopsController.select(stop: self.stopPublicId.uppercased(), returnResult: true)
               if success {
                  self.showSheet = false
                  self.routesController.deselect()
                  self.vehiclesController.deselect()
                  Analytics.shared.capture(event: .Stops_Select_FromTextInput, properties: ["stopPublicId": self.stopPublicId.uppercased()])
               } else {
                  self.showErrorLabel = true
               }
            }) {
               Image(systemName: "text.magnifyingglass")
                  .font(.system(size: 40, weight: .bold, design: .default))
                  .foregroundColor(stopPublicId.count > 0 ? Color(.white) : Color(.secondaryLabel))
            }
            .disabled(stopPublicId.count == 0)
            .padding()
            .background(stopPublicId.count > 0 ? Color(.systemBlue) : Color("BackgroundSecondary") )
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

         VStack(spacing: 10) {
            Text("Enter a Stop Number")
               .font(.body)
               .multilineTextAlignment(.center)
            Text("(ex: C 10512)")
               .font(.footnote)
               .multilineTextAlignment(.center)
         }
         .padding()

      }
   }
}
