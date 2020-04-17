//
//  RowView.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RowView: View {
  @Binding var vehicle: Vehicle
  
  let checkmark = Image(systemName: "checkmark")
  
  var body: some View {
    VStack {
      Text(String(vehicle.busNumber))
      Text("Direction: \(vehicle.direction)")
    }
  }
}

struct RowView_Previews: PreviewProvider {
  static var previews: some View {
    RowView(
      vehicle: .constant( Vehicle(routeNumber: "-", busNumber: 0, direction: "-", lat: 0.0, lng: 0.0) )
    )
  }
}

