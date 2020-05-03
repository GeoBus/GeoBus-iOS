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
      RouteBadge(routeNumber: annotation.routeNumber)
      Text("to")
        .font(.footnote)
        .foregroundColor(Color(.tertiaryLabel))
      Text(annotation.lastStopInRoute)
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(Color(.label))
    }
    
  }
  
}
