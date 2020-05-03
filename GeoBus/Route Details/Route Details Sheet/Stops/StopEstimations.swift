//
//  StopEstimations.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopEstimations: View {
  
  @ObservedObject var estimationsStorage: EstimationsStorage
 
  var body: some View {

    VStack(alignment: .leading) {
      
      HStack {
        Text("Next on this stop")
          .font(.footnote)
          .fontWeight(.medium)
          .foregroundColor(Color(.tertiaryLabel))
        Spacer()
        EstimatedIcon()
      }
      .padding(.bottom, 8)
      
      if estimationsStorage.isLoading {
        
        Text("Loading...")
          .font(.footnote)
          .foregroundColor(Color(.tertiaryLabel))
        
      } else {
        
        if estimationsStorage.estimations.count > 0 {
          
          ForEach(estimationsStorage.estimations) { estimation in
            EstimationView(estimation: estimation)
          }.onDisappear() {
            self.estimationsStorage.set(state: .idle)
          }
          
        } else {
          Text("Nothing to show here.")
            .font(.footnote)
            .foregroundColor(Color(.tertiaryLabel))
        }
      }
      
    }
    .padding(.horizontal)
    .padding(.bottom)
    
  }

}
