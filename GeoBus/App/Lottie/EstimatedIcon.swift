//
//  LoadingView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct EstimatedIcon: View {

   @State var play: Bool = true

   var body: some View {
      HStack {
         LottieView(name: "estimated-icon", loopMode: .loop, aspect: .scaleAspectFit, play: $play)
            .frame(width: 15, height: 15)
            .padding(.leading, -2)
         Text("Estimated")
            .font(Font.system(size: 11, weight: .medium, design: .default) )
            .foregroundColor(Color(.systemOrange))
            .padding(.leading, -5)
      }
   }
}


