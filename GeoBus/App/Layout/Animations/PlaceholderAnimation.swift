//
//  PlaceholderAnimation.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 30/10/2022.
//

import SwiftUI

// Create an immediate, looping animation
extension View {
   func animatePlaceholder(binding: Binding<Double>) -> some View {
      
      let minOpacity: Double = 0.5
      let animationSpeed: Double = 1
      
      return onAppear {
         withAnimation(.easeInOut(duration: animationSpeed).repeatForever(autoreverses: true)) {
            binding.wrappedValue = minOpacity
         }
      }
      
   }
}
