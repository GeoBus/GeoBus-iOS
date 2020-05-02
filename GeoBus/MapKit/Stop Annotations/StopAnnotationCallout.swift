//
//  StopAnnotationCallout.swift
//  GeoBus
//
//  Created by João on 02/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopAnnotationCallout: View {
  
  @ObservedObject var estimationsStorage: EstimationsStorage
  
  var body: some View {
    VStack {
      if estimationsStorage.estimations.count > 0 {
        
        ForEach(estimationsStorage.estimations) { estimation in
          StopEstimations(estimation: estimation)
        }.onDisappear() {
          self.estimationsStorage.set(state: .idle)
        }
        
      } else {
        Text("Nothing to show here.")
          .font(.footnote)
          .foregroundColor(Color(.tertiaryLabel))
      }
      
    }
    .onAppear() {
      self.estimationsStorage.set(state: .syncing)
    }
  }
  
}
