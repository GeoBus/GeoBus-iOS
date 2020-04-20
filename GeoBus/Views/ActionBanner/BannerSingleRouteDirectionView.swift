//
//  BannerSingleRouteDirectionView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct BannerSingleRouteDirectionView: View {
  var body: some View {
    HStack {
      VStack {
        Circle()
          .frame(width: 20, height: 20)
      }
      VStack(alignment: .leading) {
        Text("Portas de Benfica")
          .font(.footnote)
      }
      
    }
  }
}
