//
//  Chip.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 30/10/2022.
//

import SwiftUI

struct Chip: View {
   
   let icon: Image
   let text: Text
   let color: Color
   let showContent: Bool
   
   @State private var placeholderOpacity: Double = 1
   
   
   init(icon: Image, text: Text, color: Color, showContent: Bool = true) {
      self.icon = icon
      self.text = text
      self.color = color
      self.showContent = showContent
   }
   
   
   var actualContent: some View {
      HStack(alignment: .center) {
         icon
         text
         Spacer()
      }
      .font(Font.system(size: 15, weight: .medium))
      .padding()
      .foregroundColor(color)
      .frame(maxWidth: .infinity)
      .background(color.opacity(0.1))
      .cornerRadius(10)
   }
   
   
   var placeholder: some View {
      HStack(alignment: .center) {
         Circle()
            .frame(width: 15, height: 15)
         Rectangle()
            .frame(width: 90, height: 12)
         Spacer()
      }
      .font(Font.system(size: 15, weight: .medium))
      .padding()
      .foregroundColor(Color("PlaceholderShape"))
      .frame(maxWidth: .infinity)
      .background(Color("PlaceholderShape").opacity(0.3))
      .cornerRadius(10)
      .opacity(placeholderOpacity)
      .animatePlaceholder(binding: $placeholderOpacity)
   }
   
   
   var body: some View {
      if (showContent) {
         actualContent
      } else {
         placeholder
      }
   }
   
}
