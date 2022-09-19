//
//  InfoButton.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 15/09/2022.
//

import SwiftUI

struct SquareButton: View {

   private let icon: String
   private let iconSize: CGFloat

   init(icon: String, size: CGFloat = 30) {
      self.icon = icon
      self.iconSize = size
   }

   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 10)
            .fill(Color(.tertiarySystemBackground))
            .shadow(radius: 2)
         Image(systemName: icon)
            .font(Font.system(size: iconSize, weight: .regular, design: .default))
            .foregroundColor(Color(.systemBlue))
      }
      .aspectRatio(1, contentMode: .fit)
      .frame(width: 55)
   }

}
