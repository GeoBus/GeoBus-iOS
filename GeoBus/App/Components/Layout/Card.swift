//
//  Card.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct Card<Content: View>: View {

   var content: () -> Content
   
   init(@ViewBuilder content: @escaping () -> Content) {
      self.content = content
   }

   var body: some View {
      VStack(spacing: 15, content: self.content)
         .padding(25)
         .frame(maxWidth: .infinity)
         .background(Color(.systemBackground))
         .cornerRadius(20)
   }
}
