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
  var direction: Int
  
  var body: some View {
    
    HStack {
      VStack {
        Text((orderInRoute < 10 ? "0\(orderInRoute)" : "\(orderInRoute)" ))
          .font(.caption)
          .fontWeight(.bold)
          .foregroundColor(Color(.white))
      }
      .padding(7)
      .background(getColor(for: direction))
      .cornerRadius(.infinity)
      .padding(.trailing, 3)
      
      
      Text(name)
        .fontWeight(.medium)
        .foregroundColor(Color(.label))
      
      Spacer()
    }
    
  }
  
  func getColor(for direction: Int) -> Color {
    switch direction {
      case 0: return Color(.systemGreen)
      case 1: return Color(.systemBlue)
      default: return Color(.systemBlue)
    }
  }
  
}
