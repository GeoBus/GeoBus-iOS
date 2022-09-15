//
//  RouteVariantWarning.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct VariantWarning: View {
  
  var qty: Int
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "info.circle.fill")
          .font(.callout)
        Text("This route may have \(qty) alternative paths.")
          .font(.callout)
          .fixedSize(horizontal: true, vertical: true)
      }
    }
    .padding()
    .foregroundColor(Color(.systemOrange))
    .background(Color(.systemOrange).opacity(0.2))
    .cornerRadius(10)
    
  }
}
