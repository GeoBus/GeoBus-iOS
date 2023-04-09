//
//  RouteVariantWarning.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct VariantWarning: View {
   
   var qty: Int
   
   var body: some View {
      Chip(
         icon: Image(systemName: "info.circle.fill"),
         text: Text("This route may have \(qty) alternative paths."),
         color: Color(.systemOrange)
      )
   }
   
}
