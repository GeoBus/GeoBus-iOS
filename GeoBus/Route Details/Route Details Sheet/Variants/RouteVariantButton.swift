//
//  RouteVariantButton.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteVariantButton: View {
  
  var variantName: String
  
  var isSelected: Bool
  
  
  var body: some View {
    VStack {
      Text(variantName)
        .font(.callout)
    }
    .padding()
    .foregroundColor(isSelected ? .white : Color(.secondaryLabel))
    .background(isSelected ? Color(.systemBlue) : Color(.secondarySystemBackground))
    .cornerRadius(10)
  }
}
