//
//  LoadingView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct LeftArrow: View {
  
  @State var play: Bool = true
  
  var body: some View {
    LottieView(name: "arrow", loopMode: .loop, duration: 2, aspect: .scaleAspectFit, play: $play)
      .frame(width: 40, height: 30)
      .rotationEffect(.degrees(180))
  }
}


