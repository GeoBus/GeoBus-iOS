//
//  StopSearchView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct StopSearch: View {

   @ObservedObject var appstate = Appstate.shared

   var body: some View {
      SquareButton(icon: "mail.and.text.magnifyingglass", size: 26)
         .onTapGesture() {
            TapticEngine.impact.feedback(.medium)
            appstate.present(sheet: .carris_stopSelector)
         }
   }
}


struct StopSearchView: View {
   
   var body: some View {
      ScrollView() {
         VStack {
            Text("Search Stop")
               .font(.largeTitle)
               .fontWeight(.bold)
               .padding(.vertical, 30)
            SearchStopInput()
         }
         .padding()
      }
      .background(Color("BackgroundPrimary"))
   }
   
}
