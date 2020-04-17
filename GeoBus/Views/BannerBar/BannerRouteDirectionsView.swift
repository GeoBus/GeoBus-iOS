//
//  BannerRouteDirectionsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct BannerRouteDirectionsView: View {
  var body: some View {
    HStack {
      BannerSingleRouteDirectionView()
      BannerSingleRouteDirectionView()
    }
  }
}
