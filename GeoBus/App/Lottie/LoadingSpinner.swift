//
//  LoadingSpinner2.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/10/2022.
//

import SwiftUI

struct LoadingSpinner: View {
   
   @State var isAnimating: Bool = false
   let timing: Double
   
   let frame: CGSize
   let primaryColor: Color
   
   init(color: Color = .green, size: CGFloat = 20, speed: Double = 0.1) {
      timing = speed * 4
      frame = CGSize(width: size, height: size)
      primaryColor = color
   }
   
   var body: some View {
      Circle()
         .trim(from: 0.6, to: 1.0)
         .stroke(primaryColor,
                 style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
         )
         .animation(Animation.easeInOut(duration: timing / 2).repeatForever(), value: isAnimating)
         .rotationEffect(
            Angle(degrees: isAnimating ? 360 : 0)
         )
         .animation(Animation.linear(duration: timing).repeatForever(autoreverses: false), value: isAnimating)
         .frame(width: frame.width, height: frame.height, alignment: .center)
         .rotationEffect(Angle(degrees: 360 * 0.15))
         .onAppear {
            isAnimating.toggle()
         }
   }
}
