//
//  AboutButton.swift
//  GeoBus
//
//  Created by João on 15/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct AboutButton: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   let icon: Image
   let text: Text
   let link: String

   var body: some View {
      Button(action: {
         guard let url = URL(string: self.link) else { return }
         UIApplication.shared.open(url)
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
         .background(Color(.systemOrange).opacity(0.05))
         .cornerRadius(10)
      }
   }
}
