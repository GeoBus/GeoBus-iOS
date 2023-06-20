//
//  Disclaimer.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 15/09/2022.
//

import SwiftUI

struct Disclaimer: View {
   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
         Text("Live data is provided by Carris free of charge.")
            .font(.system(size: 10, weight: .medium, design: .default))
            .foregroundColor(Color(.tertiaryLabel))
         Text("Accurate predictions are computed for free by a community project.")
            .font(.system(size: 10, weight: .medium, design: .default))
            .foregroundColor(Color(.tertiaryLabel))
      }
   }
}
