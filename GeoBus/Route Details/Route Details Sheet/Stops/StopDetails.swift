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
  
  var stop: Stop
  var direction: Int
  
  @ObservedObject var estimationsStorage = EstimationsStorage()
  
  @State var isSelected = false
  
  var body: some View {
    
    Button(action: {
      self.estimationsStorage.set(publicId: self.stop.publicId, state: .syncing)
      self.isSelected = !self.isSelected
      TapticEngine.impact.feedback(.medium)
    }) {
      
      VStack {
        
        StopBadge(name: stop.name, orderInRoute: stop.orderInRoute ?? -1, direction: direction)
          .padding()
        
        VStack {
          if isSelected {
            HorizontalLine()
            StopEstimations(estimationsStorage: estimationsStorage)
          }
        }
        .padding(.top, -12)
        
      }
      .background(isSelected ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
      .cornerRadius(10)
      .padding(.bottom, isSelected ? 15 : 0)
      .shadow(color: Color(.secondarySystemBackground), radius: isSelected ? 1 : 0, x: 0, y: 0)
      .shadow(color: Color(.secondarySystemBackground), radius: isSelected ? 25 : 0, x: 0, y: isSelected ? 2 : 0)
    }
  }
  
}
