//
//  RouteSelectionHeaderView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteSelectionHeaderView: View {
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Find by Route")
        .font(.largeTitle)
        .fontWeight(.bold)
    }
    .padding(.top, 45)
    .padding(.bottom, 20)
  }
}
