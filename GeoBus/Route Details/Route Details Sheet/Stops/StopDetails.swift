//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct StopDetails: View {
  
  var publicId: String
  var name: String
  var orderInRoute: Int
  var direction: Route.Direction
  
  @State var isOpen = false
  
  var body: some View {
    
    Button(action: {
      self.isOpen = !self.isOpen
      TapticEngine.impact.feedback(.medium)
    }) {
      
      VStack {
        
        StopBadge(name: name, orderInRoute: orderInRoute, direction: direction)
          .padding()
        
        VStack {
          if isOpen {
            HorizontalLine()
            StopEstimations(publicId: self.publicId)
          }
        }
        .padding(.top, -12)
        
      }
      .background(isOpen ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
      .cornerRadius(10)
      .padding(.bottom, isOpen ? 15 : 0)
      .shadow(color: Color(.secondarySystemBackground), radius: isOpen ? 1 : 0, x: 0, y: 0)
      .shadow(color: Color(.secondarySystemBackground), radius: isOpen ? 25 : 0, x: 0, y: isOpen ? 2 : 0)
    }
  }
  
}
