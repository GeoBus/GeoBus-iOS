//
//  ConnectionErrorMessage.swift
//  GeoBus
//
//  Created by João on 26/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SyncingRoutesMessage: View {
    
  var body: some View {
      
    VStack(alignment: .leading) {
      Text("Syncing Routes...")
        .font(Font.system(size: 15, weight: .bold, design: .default))
        .foregroundColor(Color(.tertiaryLabel))
    }
      
    }
}
