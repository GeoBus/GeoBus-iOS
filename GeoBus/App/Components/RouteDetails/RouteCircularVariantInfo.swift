//
//  RouteVariantWarning.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteCircularVariantInfo: View {
   var body: some View {
      VStack {
         HStack {
            Image(systemName: "repeat")
               .font(.callout)
            Text("This is a circular route.")
               .font(.callout)
               .fixedSize(horizontal: true, vertical: true)
            Spacer()
         }
      }
      .padding()
      .foregroundColor(Color(.systemBlue))
      .background(Color(.systemBlue).opacity(0.2))
      .cornerRadius(10)
   }
}
