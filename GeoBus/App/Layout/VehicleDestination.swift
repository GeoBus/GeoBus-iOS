//
//  VehicleDestination.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI





struct DestinationText: View {
   
   let destination: String?
   
   @State private var placeholderOpacity: Double = 1
   
   
   var placeholder: some View {
      HStack(alignment: .center, spacing: 4) {
         Image(systemName: "arrow.forward")
            .font(.system(size: 8, weight: .bold, design: .default))
            .foregroundColor(Color("PlaceholderText"))
         Rectangle()
            .frame(width: 80, height: 12)
            .foregroundColor(Color("PlaceholderShape"))
      }
      .opacity(self.placeholderOpacity)
      .animatePlaceholder(binding: self.$placeholderOpacity)
   }
   
   
   var actualContent: some View {
      HStack(spacing: 4) {
         Image(systemName: "arrow.forward")
            .font(.system(size: 8, weight: .bold, design: .default))
            .foregroundColor(Color(.tertiaryLabel))
         Text(self.destination!)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .lineLimit(1)
      }
   }
   
   
   var body: some View {
      if (self.destination != nil) {
         actualContent
      } else {
         placeholder
      }
   }
   
}
