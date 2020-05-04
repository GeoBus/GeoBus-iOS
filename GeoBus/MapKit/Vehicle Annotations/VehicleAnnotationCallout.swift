//
//  CustomCalloutView.swift
//  GeoBus
//
//  Created by João on 01/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct VehicleAnnotationCallout: View {
  
  let annotation: VehicleAnnotation
  
  var body: some View {
    
    HStack {
      Text("direction:")
        .font(.footnote)
        .foregroundColor(Color(.secondaryLabel))
      Text(annotation.lastStopInRoute)
        .font(.body)
        .fontWeight(.medium)
        .lineLimit(1)
        .foregroundColor(Color(.label))
    }
    
  }
  
}
