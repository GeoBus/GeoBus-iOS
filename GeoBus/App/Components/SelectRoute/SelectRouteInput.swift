//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectRouteInput: View {
   
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController

   @Binding var showSheet: Bool

   @State var showErrorLabel: Bool = false

   @State var routeNumber = ""

   var body: some View {
      VStack {
         HStack {
            TextField("_ _ _", text: self.$routeNumber)
               .keyboardType(.numberPad)
               .font(.system(size: 40, weight: .bold, design: .default))
               .multilineTextAlignment(.center)
               .padding()
               .background(Color("BackgroundSecondary"))
               .cornerRadius(10)
               .toolbar {
                  ToolbarItemGroup(placement: .keyboard) {
                     // INCLUDE BUTTON FOR ‹B› AND ‹E›
                     // 13B and 28E
                  }
               }

            Button(action: {
               let success = carrisNetworkController.select(route: self.routeNumber.uppercased())
               if success {
                  Analytics.shared.capture(event: .Routes_Select_FromTextInput, properties: ["routeNumber": self.routeNumber.uppercased()])
                  self.showSheet = false
               } else {
                  self.showErrorLabel = true
               }
            }) {
               Image(systemName: "text.magnifyingglass")
                  .font(.system(size: 40, weight: .bold, design: .default))
                  .foregroundColor(routeNumber.count > 2 ? Color(.white) : Color(.secondaryLabel))
            }
            .padding()
            .disabled(routeNumber.count == 0)
            .background(routeNumber.count > 2 ? Color(.systemBlue) : Color("BackgroundSecondary") )
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
