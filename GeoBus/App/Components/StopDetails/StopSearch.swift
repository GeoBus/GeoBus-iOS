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
            VStack {
               SheetHeader(title: Text("Find Stops"), toggle: $showSearchStopSheet)
               SearchStopInput(showSheet: $showSearchStopSheet)
            }
            .padding(.horizontal)
            .readSize { size in
               viewSize = size
            }
            .presentationDetents([.height(viewSize.height)])
         }
   }
}
