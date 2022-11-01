//
//  SheetHeader.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SheetHeader: View {
   
   @ObservedObject private var appstate = Appstate.shared
   
   let title: Text
   
   var body: some View {
      VStack {
         HStack {
            Spacer()
            Button(action: { appstate.unpresent() }) {
               Text("Close")
                  .fontWeight(.bold)
            }
            .padding(25)
         }
         title
            .font(.largeTitle)
            .fontWeight(.bold)
      }
      .padding(.bottom, 20)
   }
}
