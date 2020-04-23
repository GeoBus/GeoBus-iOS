//
//  RouteVariantWarning.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteVariantWarning: View {
  
  var qty: Int
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "info.circle.fill")
          .font(.callout)
        Text("This route has \(qty) alternative paths.")
          .font(.callout)
          .fixedSize(horizontal: true, vertical: true)
      }
    }
    .padding()
    .foregroundColor(.orange)
    .background(Color(red: 1.00, green: 0.90, blue: 0.80))
    .cornerRadius(10)
    
  }
}
