//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct ContentView: View {
   
   var body: some View {

      VStack(alignment: .trailing, spacing: 0) {
         MapView()
            .edgesIgnoringSafeArea(.vertical)
         NavBar()
            .edgesIgnoringSafeArea(.vertical)
      }

   }

}
