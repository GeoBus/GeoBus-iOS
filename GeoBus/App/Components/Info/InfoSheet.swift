//
//  StopSearchView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct InfoSheet: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var mapController: MapController

   @State var showInfoSheet: Bool = false


   var body: some View {
      SquareButton(icon: "info.circle", size: 28)
         .onTapGesture() {
            TapticEngine.impact.feedback(.medium)
            self.showInfoSheet = true
         }
         .sheet(isPresented: self.$showInfoSheet) {
            ScrollView(.vertical, showsIndicators: true) {
               VStack {
                  SheetHeader(title: Text("Welcome!"), toggle: $showInfoSheet)
                  Spacer()
               }
            }
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
            .presentationDetents([.medium, .large])
         }
   }

}
