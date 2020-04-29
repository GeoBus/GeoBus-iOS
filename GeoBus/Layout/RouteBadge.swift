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
    Text(routeNumber)
      .font(.footnote)
      .fontWeight(.heavy)
      .foregroundColor(Color(.black))
      .padding(.horizontal, 7)
      .padding(.vertical, 2)
      .background( RoundedRectangle(cornerRadius: 10).foregroundColor(Color(.systemYellow)) )
      .padding(.trailing, 0)
  }
  
}
