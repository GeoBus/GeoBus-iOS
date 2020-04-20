//
//  BannerRefreshTimerView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RefreshStatusView: View {
  
  let interval: CGFloat
  
  @Binding var isAutoUpdating: Bool
  
  private let defaultAnimationSpeed: CGFloat = 1.01 // The default duration of the "loader-interval" animation
  
  var body: some View {
    LottieView(
      name: "reversed-progress-bar",
      loopMode: .loop,
      duration: (interval / defaultAnimationSpeed),
      play: $isAutoUpdating
    )
      .frame(height: 3)
      .background(Color.green)
  }
}
