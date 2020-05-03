//
//  AnnotationBanner.swift
//  GeoBus
//
//  Created by João on 02/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct AnnotationBanner: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  var selectedStopAnnotation: StopAnnotation?
  
  
  var body: some View {
    
    VStack {
      StopBadge(name: selectedStopAnnotation?.name ?? "-", orderInRoute: selectedStopAnnotation?.orderInRoute ?? -1, direction: 1)
        .padding([.leading, .top, .trailing])
      HorizontalLine()
      StopEstimations(estimationsStorage: EstimationsStorage(stopPublicId: selectedStopAnnotation?.publicId ?? "", state: .syncing))
    }
//    .background(colorScheme == .dark ? Color(.systemGray5).opacity(0.9) : Color(.white).opacity(0.9))
    .background(Color(.tertiarySystemBackground))
    .cornerRadius(10)
    .shadow(radius: 10)
    .padding()
    
  }
  
}
