//
//  AboutGeoBus.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct AboutGeoBus: View {

   @EnvironmentObject var carrisNetworkController: CarrisNetworkController

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
            if (carrisNetworkController.allStops.isEmpty || carrisNetworkController.allRoutes.isEmpty) {
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
                     DataProvidersCard()
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
