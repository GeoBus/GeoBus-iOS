//
//  LoadingView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct LiveConnectionIcon: View {
  
  @State var play: Bool = true
  
  var body: some View {
    LottieView(name: "live-icon", loopMode: .loop, aspect: .scaleAspectFit, play: $play)
      .frame(width: 15, height: 15)
  }
}


