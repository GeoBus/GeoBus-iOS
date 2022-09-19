//
//  AboutLiveData.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct LiveDataCard: View {

   private let cardColor: Color = Color(.systemMint)

   var body: some View {
      Card {
         Image(systemName: "dot.radiowaves.left.and.right")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(cardColor)
         Text("Live Data")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(cardColor)
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
   }
}
