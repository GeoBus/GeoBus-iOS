//
//  LoadingView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
  
  @Binding var play: Bool
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color(red: 1, green: 1, blue: 1, opacity: 0.6))
      LottieView(name: "circular-loader", loopMode: .loop, duration: 1, play: $play)
    }
  }
}


