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
    .foregroundColor(isSelected ? .white : .black)
    .background(isSelected ? Color.blue : Color(red: 0.95, green: 0.95, blue: 0.95))
    .cornerRadius(10)
  }
}
