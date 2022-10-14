//
//  VehicleDestination.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct VehicleDestination: View {
   
   public let routeNumber: String
   public let destination: String
   
   var body: some View {
      HStack(spacing: 4) {
         RouteBadgePill(routeNumber: self.routeNumber)
         Image(systemName: "arrow.forward")
            .font(.system(size: 8, weight: .bold, design: .default))
            .foregroundColor(Color(.tertiaryLabel))
         Text(self.destination)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .lineLimit(1)
      }
   }
   
}

