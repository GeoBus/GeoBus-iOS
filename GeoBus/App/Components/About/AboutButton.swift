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
               .frame(width: 35, alignment: .center)
            self.text
               .padding(.leading, 5)
            Spacer()
            Image(systemName: "arrow.up.right.square")
               .font(Font.system(size: 25))
               .foregroundColor(Color(.secondaryLabel).opacity(0.25))
         }
         .padding()
         .padding(.vertical, 2)
         .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
         .cornerRadius(10)
      }
   }
}
