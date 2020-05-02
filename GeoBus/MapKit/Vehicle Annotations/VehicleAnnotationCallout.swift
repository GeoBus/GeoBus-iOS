//
//  CustomCalloutView.swift
//  GeoBus
//
//  Created by João on 01/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct VehicleAnnotationCallout: View {
  
  let direction: String
  
  var body: some View {
    VStack {
      Text("to \(direction)")
      Text("Hello, World!")
      Text("Hello, World!")
      Text("Hello, World!")
      Text("Hello, World!")
      Text("Hello, World!")
      HStack{
        Image(systemName: "circle")
        Text("Hello, World!")
      }
    }
  }
}
