//
//  Pulse.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/10/2022.
//

import SwiftUI


struct PulseLabel: View {
   
   let accent: Color
   let label: Text
   
   var body: some View {
      HStack(spacing: 0) {
         Pulse(size: 15, accent: self.accent)
         label
            .font(Font.system(size: 11, weight: .medium, design: .default) )
            .foregroundColor(self.accent)
      }
   }
   
}



struct Pulse: View {
   
   let speed: Double = 3
   
   let size: CGFloat
   let accent: Color
   
   @State var scale: Double = 0.0
   @State var opacity: Double = 1.0
   
   
   var body: some View {
      ZStack {
         Circle()
            .scale(scale)
            .fill(accent)
            .opacity(opacity)
            .animation(
               .easeOut(duration: speed)
               .repeatForever(autoreverses: false),
               value: [scale, opacity])
         Circle()
            .fill(accent)
            .frame(width: size/4, height: size/4, alignment: .center)
      }
      .frame(width: size, height: size, alignment: .center)
      .onAppear {
         scale = 1.0
         opacity = 0.0
      }
   }
   
}
