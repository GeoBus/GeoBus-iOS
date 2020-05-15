//
//  About.swift
//  GeoBus
//
//  Created by João on 15/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct About: View {
  var body: some View {
    
    VStack {
      Text("Olá! If you need help with GeoBus, or have ideas to improve it, please send a message through our social network! We'll be delighted to hear your opinion.")
    }
    .padding()
    .background(Color(.systemGreen).opacity(0.25))
    .cornerRadius(10)
    .padding()
    
  }
}
