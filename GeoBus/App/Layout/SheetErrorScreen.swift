//
//  SheetErrorScreen.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 30/10/2022.
//

import SwiftUI

struct SheetErrorScreen: View {
   
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      VStack(alignment: .center, spacing: 15) {
         Image(systemName: "exclamationmark.octagon.fill")
            .foregroundColor(Color(.systemRed))
            .font(Font.system(size: 50, weight: .bold))
         Text("Connection Error")
            .font(Font.system(size: 24, weight: .bold, design: .default) )
            .foregroundColor(Color(.label))
         Text("A connection to the API was not possible.")
            .font(Font.system(size: 18, weight: .medium, design: .default) )
            .foregroundColor(Color(.secondaryLabel))
         Button(action: {
            carrisNetworkController.refresh()
         }, label: {
            Text("Try Again")
               .font(Font.system(size: 18, weight: .bold))
               .foregroundColor(.white)
               .padding(.vertical, 10)
               .padding(.horizontal, 20)
               .frame(maxWidth: .infinity)
               .background(Color(.systemBlue))
               .cornerRadius(10)
               .padding(.top, 30)
         })
      }
      .padding()
      .frame(maxWidth: .infinity)
   }
}
