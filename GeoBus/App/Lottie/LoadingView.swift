//
//  LoadingView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct LoadingView: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @State var play: Bool = true

   var body: some View {
      ZStack {

         RoundedRectangle(cornerRadius: 10)
            .fill( colorScheme == .dark ? Color(.systemGray4) : Color(.systemGray5) )

         LottieView(
            name: colorScheme == .dark ? "circular-loader-white" : "circular-loader-green",
            loopMode: .loop,
            duration: 1,
            play: $play
         )

      }
   }
}


