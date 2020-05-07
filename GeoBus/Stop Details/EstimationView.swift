//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import Combine

struct EstimationView: View {
  
  var estimation: Estimation
  
  var body: some View {
    
    HStack {
      RouteBadge(routeNumber: estimation.routeNumber)
      Text("to")
        .font(.footnote)
        .foregroundColor(Color(.tertiaryLabel))
      Text(estimation.destination)
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(Color(.label))
      Spacer()
      Text("in ±")
        .font(.footnote)
        .foregroundColor(Color(.tertiaryLabel))
      Text(getTimeInterval(for: estimation.time))
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(Color(.label))
    }
    .padding(.bottom, 8)
    
  }
  
  
  func getTimeInterval(for eta: String) -> String {
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    let estimation = formatter.date(from: eta)
    let now = Date()
    
    let interval = estimation?.timeIntervalSince(now) ?? TimeInterval()
  
    let minutes = Int(interval / 60)
    
    return "\(minutes) min"
    
  }
  
  
}

