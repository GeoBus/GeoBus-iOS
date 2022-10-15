//
//  Spinner.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/10/2022.
//

import SwiftUI

struct Spinner: View {
   
   @Environment(\.colorScheme) var colorScheme: ColorScheme
   
   private let timing: Double = 0.5
   private let size: CGFloat = 20.0
   
   @State var trim: Double = 0.4
   @State var rotationAngle: Double = 0.0
   
   var body: some View {
      Circle()
         .trim(from: trim, to: 1.0)
         .stroke(colorScheme == .dark ? .white : .green,
                 style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
         )
         .rotationEffect(.degrees(rotationAngle))
         .frame(width: size, height: size, alignment: .center)
         .onAppear {
            withAnimation(.linear(duration: timing * 2).repeatForever()) {
               trim = 0.8
            }
            withAnimation(.linear(duration: timing).repeatForever(autoreverses: false)) {
               rotationAngle = 360.0
            }
         }
   }
   
}
