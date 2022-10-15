//
//  LoadingPulse.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/10/2022.
//

import SwiftUI

struct LoadingPulse: View {
   @State var isAnimating: Bool = false
   let timing: Double
   
   let maxCounter: Int = 3
   
   let frame: CGSize
   let primaryColor: Color
   
   init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.75) {
      timing = speed * 4
      frame = CGSize(width: size, height: size)
      primaryColor = color
   }
   
   var body: some View {
      ZStack {
         
         ForEach(0..<maxCounter, id: \.self) { index in
            Circle()
               .scale(isAnimating ? 1.0 : 0.0)
               .fill(primaryColor)
               .opacity(isAnimating ? 0.0 : 1.0)
               .animation(
                  Animation.easeOut(duration: timing)
                     .repeatForever(autoreverses: false)
                     .delay(Double(index) * timing / 3),
                  value: isAnimating
               )
            
         }
      }
      .frame(width: frame.width, height: frame.height, alignment: .center)
      .onAppear {
         isAnimating.toggle()
      }
   }
}






struct LoadingPulse2: View {
   @State var isAnimating: Bool = false
   let timing: Double
   
   let maxCounter: Int = 3
   
   let frame: CGSize
   let primaryColor: Color
   
   init(color: Color = .black, size: CGFloat = 50, speed: Double = 1) {
      timing = speed * 4
      frame = CGSize(width: size, height: size)
      primaryColor = color
   }
   
   var body: some View {
      ZStack {
         
         ForEach(0..<maxCounter, id: \.self) { index in
            Circle()
               .stroke(
                  primaryColor.opacity(isAnimating ? 0.0 : 1.0),
                  style: StrokeStyle(lineWidth: isAnimating ? 0.0 : 10.0))
               .scaleEffect(isAnimating ? 1.0 : 0.0)
               .animation(
                  Animation.easeOut(duration: timing)
                     .repeatForever(autoreverses: false)
                     .delay(Double(index) * timing/4),
                  value: isAnimating
               )
         }
      }
      .frame(width: frame.width, height: frame.height, alignment: .center)
      .onAppear {
         isAnimating.toggle()
      }
   }
}
