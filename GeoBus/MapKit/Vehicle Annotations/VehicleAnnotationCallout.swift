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
    
    VStack(alignment: .leading) {
      HStack {
        RouteBadge(routeNumber: annotation.routeNumber)
        Text("to")
          .font(.footnote)
          .foregroundColor(Color(.secondaryLabel))
        Text(annotation.lastStopInRoute)
          .font(.body)
          .fontWeight(.medium)
          .lineLimit(1)
          .foregroundColor(Color(.label))
      }
      HStack {
        Text(
          "Last seen \(getTimeInterval(for: annotation.lastGpsTime)) ago"
            + " (Bus #\(annotation.busNumber))")
          .font(.footnote)
          .foregroundColor(Color(.secondaryLabel))
          .padding(.top, 4)
      }
    }
    
  }
  
  
  func getTimeInterval(for eta: String) -> String {
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    let now = Date()
    let estimation = formatter.date(from: eta) ?? now
    
    let seconds = now.timeIntervalSince(estimation)
    
    return "\( Int(seconds) ) sec"
    
  }
  
}
