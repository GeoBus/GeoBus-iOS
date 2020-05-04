//
//  RouteBadge.swift
//  GeoBus
//
//  Created by João on 29/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteBadge: View {
  
  let routeNumber: String
  
  var body: some View {
    
    VStack {
      Text(routeNumber)
        .font(.footnote)
        .fontWeight(.heavy)
        .lineLimit(1)
        .foregroundColor(Color(.black))
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
    }
    .background(Color(.systemYellow))
    .cornerRadius(10)
    
  }
  
}
