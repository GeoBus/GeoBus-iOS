//
//  LoadingView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
  
  @State var play: Bool = true
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color(.white).opacity(0.5))
        .cornerRadius(10)
      LottieView(name: "circular-loader", loopMode: .loop, duration: 1, play: $play)
    }
  }
}


