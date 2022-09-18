//
//  StopSearchView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct InfoSheet: View {

   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController

   @State var showInfoSheet: Bool = false


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

                  // Intro
                  VStack(spacing: 10) {
                     Text("Olá 👋")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                     Text("Thanks for giving GeoBus a try!")
                        .font(.headline)
                        .fontWeight(.bold)
                  }
                  .padding(.top, 70)
                  .padding(.bottom, 15)

                  // Sync Status Handler
                  SyncStatus()

                  Divider()

                  // Live Data Explainer
                  Card {
                     Image(systemName: "dot.radiowaves.left.and.right")
                        .font(Font.system(size: 30, weight: .regular))
                        .foregroundColor(Color(.systemMint))
                     Text("Live Data")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemMint))
                     Text("All data is fetched directly from Carris servers in real time, free of charge.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.label))
                     Text("Sometimes their service is unavailable or changes unexpectedly. In this situations, the only option is to wait and try again later.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.secondaryLabel))
                     Text("I'll do my best to keep the app working flawlessly for as long as possible.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.secondaryLabel))
                  }

                  // Location
                  Card {
                     Image(systemName: "location.fill")
                        .font(Font.system(size: 30, weight: .regular))
                        .foregroundColor(Color(.systemBlue))
                     Text("Your Location")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemBlue))
                     Text("GeoBus can show you where you are in the map, if you allow it.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.label))
                     Text("Your privacy is respected, it will not leave your device or be sold to anyone.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.secondaryLabel))
                     Text("Pro tip: tap and hold the location button to zoom in to street level!")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.secondaryLabel))
                  }

                  // Share
                  Card {
                     Image(systemName: "heart.fill")
                        .font(Font.system(size: 30, weight: .regular))
                        .foregroundColor(Color(.systemRed))
                     Text("Spread the Love")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemRed))
                     Text("Share GeoBus with your friends and family!")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.label))
                     Text("The more people using it the more likely it will keep working.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.secondaryLabel))
                     ShareLink(item: URL(string: "https://joao.earth/geobus/download")!) {
                        Text("Share GeoBus")
                           .font(Font.system(size: 25, weight: .bold, design: .default) )
                           .foregroundColor(Color(.white))
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(Color(.systemRed))
                           .cornerRadius(10)
                           .padding(.top, 10)
                     }
                  }

                  // Help and Socials
                  Card {
                     Image(systemName: "wand.and.stars.inverse")
                        .font(Font.system(size: 30, weight: .regular))
                        .foregroundColor(Color(.systemOrange))
                     Text("Open to Feedback")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemOrange))
                     Text("Send me a message if you need help with GeoBus, or have any ideas to improve it.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.label))
                     Text("I'll be delighted to know your opinion.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.bottom, 10)
                     AboutButton(icon: Image("Twitter"), text: Text("Twitter"), link: "https://twitter.com/johny________")
                     AboutButton(icon: Image("GitHub"), text: Text("GitHub"), link: "https://github.com/GeoBus")
                     AboutButton(icon: Image(systemName: "envelope.fill"), text: Text("Send an Email"), link: "mailto:contact@joao.earth")
                     AboutButton(icon: Image(systemName: "globe"), text: Text("Visit the Website"), link: "https://joao.earth")
                  }

                  // Close Button
                  CloseButton(isPresenting: self.$showInfoSheet)

                  // App version
                  AppVersion()
                     .padding(.vertical, 20)

               }
               .padding(.horizontal)
            }
            .background(Color(.secondarySystemBackground))
         })
   }

}
