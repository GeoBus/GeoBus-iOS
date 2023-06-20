//
//  ContactsCard.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct ContactsCard: View {

   private let cardColor: Color = Color(.systemOrange)

   var body: some View {
      Card {
         Image(systemName: "wand.and.stars.inverse")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(cardColor)
         Text("Open to Feedback")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(cardColor)
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
         OpenExternalLinkButton(icon: Image("GitHub"), text: Text("GitHub"), link: "https://github.com/GeoBus", color: cardColor)
         OpenExternalLinkButton(icon: Image(systemName: "envelope.fill"), text: Text("Send an Email"), link: "mailto:contact@joao.earth", color: cardColor)
         OpenExternalLinkButton(icon: Image(systemName: "globe"), text: Text("Visit the Website"), link: "https://joao.earth", color: cardColor)
      }
   }
}
