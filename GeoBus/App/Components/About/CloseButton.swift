//
//  SyncStatus.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct CloseButton: View {

   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var stopsController: StopsController
   @EnvironmentObject var routesController: RoutesController

   @Binding var isPresenting: Bool


   func forceSync() {
      self.stopsController.update(forced: true)
      self.routesController.update(forced: true)
   }


   var syncError: some View {
      VStack(spacing: 15) {
         VStack(spacing: 15) {
            Text("Unfortunately it was not possible to retrieve information from Carris.")
            Text("Please try again.")
         }
         .multilineTextAlignment(.center)
         .font(.headline)
         .fontWeight(.semibold)
         .foregroundColor(Color(.secondaryLabel))
         .padding(.horizontal)
         Text("If the error persists, the only option is to wait and try again later. Unfortunately the app cannot function without this first step.")
            .multilineTextAlignment(.center)
            .font(.subheadline)
            .foregroundColor(Color(.secondaryLabel))
            .padding(.horizontal)
         Button(action: {
            self.forceSync()
         }, label: {
            VStack {
               Text("Try Again")
            }
            .font(Font.system(size: 25, weight: .bold, design: .default) )
            .foregroundColor(Color(.white))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top, 10)
         })
      }
      .interactiveDismissDisabled()
   }

   var isSyncing: some View {
      VStack(spacing: 15) {
         HStack(spacing: 20) {
            ProgressView()
               .scaleEffect(1.5)
            Text("Please wait...")
         }
         .font(Font.system(size: 25, weight: .bold, design: .default) )
         .foregroundColor(Color(.secondaryLabel))
         .padding()
         .frame(maxWidth: .infinity)
         .background(Color(.tertiarySystemFill))
         .cornerRadius(10)
         .padding(.top, 10)
         Text("This should take about a minute.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
            .padding(.horizontal)
      }
      .interactiveDismissDisabled()
   }

   var hasSynced: some View {
      Button(action: {
         self.isPresenting = false
      }, label: {
         VStack {
            Text("Close")
         }
         .font(Font.system(size: 25, weight: .bold, design: .default) )
         .foregroundColor(Color(.white))
         .padding()
         .frame(maxWidth: .infinity)
         .background(Color(.systemBlue))
         .cornerRadius(10)
         .padding(.top, 10)
      })
   }

   

   var body: some View {
      if (stopsController.allStops.isEmpty || routesController.allRoutes.isEmpty) {
         if (appstate.stops == .error || appstate.routes == .error) {
            syncError
         } else {
            isSyncing
         }
      } else {
         hasSynced
      }
   }
}
