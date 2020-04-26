//
//  ConnectionErrorMessage.swift
//  GeoBus
//
//  Created by João on 26/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct ConnectionErrorMessage: View {
    
  var body: some View {
      
      VStack(alignment: .leading) {
          Text("Connection Error")
            .font(Font.system(size: 15, weight: .bold, design: .default))
            .foregroundColor(Color(.systemRed))
          Text("That's because you are not connected to the internet or our server is down.")
            .font(Font.system(size: 12, weight: .medium, design: .default))
            .foregroundColor(Color(.tertiaryLabel))
          Text("Click here to retry ↺")
            .font(Font.system(size: 12, weight: .bold, design: .default))
            .foregroundColor(Color(.secondaryLabel))
        }
      
    }
}
