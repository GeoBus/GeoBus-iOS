//
//  ConnectionErrorMessage.swift
//  GeoBus
//
//  Created by João on 26/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct ChooseRouteScreen: View {
  
  let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
  let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
  
  var body: some View {
    
    ZStack(alignment: .bottomTrailing) {
      VStack(alignment: .leading) {
        Spacer()
        HStack {
          Text("← Choose a Route")
            .font(Font.system(size: 15, weight: .bold, design: .default))
            .foregroundColor(Color(.secondaryLabel))
          Spacer()
        }
        Spacer()
      }
      Text("v\(version)-\(build)")
        .font(Font.system(size: 10))
        .foregroundColor(Color(.tertiaryLabel))
    }
    
  }
  
}
