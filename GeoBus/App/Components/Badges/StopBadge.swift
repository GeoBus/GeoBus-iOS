//
//  StopBadge.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopBadge: View {
  
  var name: String
  var orderInRoute: Int
  var direction: RouteVariantDirection
  
  var body: some View {
    
     HStack(spacing: 15) {
   
      ZStack {
        getStopIcon(for: direction)
          .renderingMode(.original)
        Text("\(orderInRoute)")
          .font(.caption)
          .fontWeight(.bold)
          .foregroundColor(Color(.white))
      }

      Text(name)
        .fontWeight(.medium)
        .foregroundColor(Color(.label))
        .multilineTextAlignment(.leading)
      
      Spacer()
    
    }
    
  }
  
  func getStopIcon(for direction: RouteVariantDirection) -> Image {
    switch direction {
      case .ascending:
        return Image("PinkCircle")
      case .descending:
        return Image("OrangeCircle")
      case .circular:
        return Image("BlueCircle")
    }
  }
  
}
