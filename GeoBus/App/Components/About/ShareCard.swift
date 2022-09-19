//
//  ShareCard.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct ShareCard: View {

   @EnvironmentObject var appstate: Appstate

   private let cardColor: Color = Color(.systemPink)

    var body: some View {
       Card {
          Image(systemName: "heart.fill")
             .font(Font.system(size: 30, weight: .regular))
             .foregroundColor(cardColor)
          Text("Spread the Love")
             .font(.title)
             .fontWeight(.bold)
             .foregroundColor(cardColor)
          Text("Share GeoBus with your friends and family!")
             .multilineTextAlignment(.center)
             .font(.headline)
             .fontWeight(.semibold)
             .foregroundColor(Color(.label))
          Text("The more people using it the more likely it will keep working.")
             .multilineTextAlignment(.center)
             .font(.headline)
             .fontWeight(.semibold)
             .foregroundColor(Color(.secondaryLabel))
          ShareLink(item: URL(string: "https://joao.earth/geobus/download")!) {
             Text("Share GeoBus")
                .font(Font.system(size: 25, weight: .bold, design: .default) )
                .foregroundColor(Color(.white))
                .padding()
                .frame(maxWidth: .infinity)
                .background(cardColor)
                .cornerRadius(10)
                .padding(.top, 10)
          }
          .simultaneousGesture(
            TapGesture()
               .onEnded { val in
                  self.appstate.capture(event: "General-Share-ShareIntent")
               }
          )
       }
    }
}
