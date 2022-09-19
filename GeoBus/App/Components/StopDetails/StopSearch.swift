//
//  StopSearchView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct StopSearch: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var mapController: MapController
   @EnvironmentObject var stopsController: StopsController

   @State var showSearchStopSheet: Bool = false
   @State private var viewSize = CGSize()


   var body: some View {
      SquareButton(icon: "mail.and.text.magnifyingglass", size: 26)
         .onTapGesture() {
            TapticEngine.impact.feedback(.medium)
            self.showSearchStopSheet = true
         }
         .sheet(isPresented: self.$showSearchStopSheet) {
            ScrollView() {
               VStack {
                  Text("Search Stop")
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .padding(.vertical, 30)
                  SearchStopInput(showSheet: $showSearchStopSheet)
               }
               .padding()
               .readSize { size in
                  viewSize = size
               }
            }
            .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
            .presentationDetents([.height(viewSize.height)])
         }
   }
}
