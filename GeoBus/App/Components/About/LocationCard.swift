//
//  LocationCard.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct LocationCard: View {

   private let cardColor: Color = Color(.systemBlue)

   var body: some View {
      Card {
         Image(systemName: "location.fill")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(cardColor)
         Text("Your Location")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(cardColor)
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
   }
}
