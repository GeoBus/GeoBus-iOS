//
//  AboutGeoBus.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct AboutGeoBus: View {

   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController

   @State private var showInfoSheet: Bool = false


   var introduction: some View {
      VStack(spacing: 10) {
         Text("Olá 👋")
            .font(.largeTitle)
            .fontWeight(.bold)
         Text("Thanks for using GeoBus!")
            .font(.headline)
            .fontWeight(.bold)
      }
   }


   var body: some View {
      SquareButton(icon: "info.circle", size: 28)
         .onAppear() {
            if (stopsController.allStops.isEmpty || routesController.allRoutes.isEmpty) {
               self.showInfoSheet = true
            }
         }
         .onTapGesture() {
            TapticEngine.impact.feedback(.medium)
            self.showInfoSheet = true
         }
         .sheet(isPresented: $showInfoSheet, content: {
            ScrollView(.vertical, showsIndicators: true) {
               VStack(spacing: 30) {

                  VStack(spacing: 30) {
                     introduction
                        .padding(.top, 70)
                        .padding(.bottom, 15)
                     SyncStatus()
                     EstimationsProviderCard()
                  }
                  .padding(.horizontal)

                  Divider()

                  VStack(spacing: 30) {
                     LiveDataCard()
                     LocationCard()
                     ShareCard()
                     ContactsCard()
                     CloseButton(isPresenting: self.$showInfoSheet)
                     AppVersion()
                        .padding(.vertical, 20)
                  }
                  .padding(.horizontal)

               }
            }
            .background(Color("BackgroundPrimary"))
         })

   }

}
