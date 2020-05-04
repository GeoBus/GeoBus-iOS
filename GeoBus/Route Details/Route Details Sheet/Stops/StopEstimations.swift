//
//  StopEstimations.swift
//  GeoBus
//
//  Created by João on 03/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct StopEstimations: View {
  
  var publicId: String
  @ObservedObject var estimationsStorage: EstimationsStorage
  
  init(publicId: String) {
    self.publicId = publicId
    self.estimationsStorage = EstimationsStorage(publicId: self.publicId)
  }
  
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
          
          VStack {
            ForEach(estimationsStorage.estimations) { estimation in
              EstimationView(estimation: estimation)
            }
          }
          .padding(.bottom, -10)
          
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
