//
//  OpenExternalLinkButton.swift
//  GeoBus
//
//  Created by João on 15/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct OpenExternalLinkButton: View {

   @EnvironmentObject var appstate: Appstate

   let icon: Image
   let text: Text
   let link: String
   let color: Color

   var body: some View {
      Button(action: {
         if let urlToOpen = URL(string: self.link) {
            self.appstate.capture(event: "General-Contact-OpenLink", properties: ["URL": urlToOpen])
            UIApplication.shared.open(urlToOpen)
         }
      }) {
         HStack {
            self.icon
               .renderingMode(.template)
               .font(Font.system(size: 25))
               .foregroundColor(Color(.systemOrange))
            self.text
               .font(Font.system(size: 18, weight: .medium))
               .padding(.leading, 5)
               .foregroundColor(Color(.systemOrange))
            Spacer()
            Image(systemName: "arrow.up.right.square")
               .font(Font.system(size: 25))
               .foregroundColor(Color(.systemOrange).opacity(0.5))
         }
         .padding()
         .frame(maxWidth: .infinity)
         .background(color.opacity(0.05))
         .cornerRadius(10)
      }
   }
}
