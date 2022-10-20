//
//  SyncStatus.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct SyncStatus: View {

   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController


   var syncError: some View {
      Card {
         Image(systemName: "xmark.octagon.fill")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(Color(.systemOrange))
         Text("Service Unavailable")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(.systemOrange))
         Text("Unfortunately it was not possible to retrieve information from Carris.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.label))
         Text("It's probably because their servers are down. In this case, the best option is to wait and try again later :/")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
         Button(action: {
            carrisNetworkController.resetAndUpdateNetwork()
         }, label: {
            VStack {
               Text("Try Again")
            }
            .font(Font.system(size: 25, weight: .bold, design: .default) )
            .foregroundColor(Color(.white))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemOrange))
            .cornerRadius(10)
            .padding(.top, 10)
         })
      }
   }

   var isSyncing: some View {
      Card {
         ProgressView()
            .scaleEffect(1.5)
            .padding(.vertical, 10)
         Text("Please wait a moment while routes and stops are synced with Carris.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.label))
         Text("This should take less than a minute and only happens this once.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
            .padding(.bottom, 5)
         if (carrisNetworkController.networkUpdateProgress != nil) {
            Text("\(carrisNetworkController.networkUpdateProgress!) Routes left...")
               .multilineTextAlignment(.center)
               .font(.subheadline)
               .foregroundColor(Color(.secondaryLabel))
               .padding(.horizontal)
         } else {
            Text("Preparing synchronization...")
               .multilineTextAlignment(.center)
               .font(.subheadline)
               .foregroundColor(Color(.secondaryLabel))
               .padding(.horizontal)
         }
      }
   }

   var hasSynced: some View {
      Card {
         Image(systemName: "checkmark.seal.fill")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(Color(.systemGreen))
            .onTapGesture(count: 2, perform: {
               carrisNetworkController.resetAndUpdateNetwork()
            })
         Text("Up to Date")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(.systemGreen))
         Text("Routes and Stops are synced.")
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.label))
         Text("GeoBus will keep them updated in the background automatically.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
      }
   }



   var body: some View {
      if (appstate.stops == .loading || appstate.routes == .loading) {
         isSyncing
      } else if (appstate.stops == .error || appstate.routes == .error) {
         syncError
      } else {
         hasSynced
      }
   }
}
