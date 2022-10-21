//
//  AboutLiveData.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct DataProvidersCard: View {
   
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   private let cardColor: Color = Color(.systemTeal)
   
   @State var communityProviderIsOn: Bool = false
   
   
   var providerToggle: some View {
      Toggle(isOn: $carrisNetworkController.communityDataProviderStatus) {
         HStack {
            Image(systemName: "staroflife.circle")
               .renderingMode(.template)
               .font(Font.system(size: 25))
               .foregroundColor(cardColor)
            Text("Community ETAs")
               .font(Font.system(size: 18, weight: .bold))
               .foregroundColor(cardColor)
               .padding(.leading, 5)
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .tint(cardColor)
      .background(cardColor.opacity(0.05))
      .cornerRadius(10)
      .onChange(of: carrisNetworkController.communityDataProviderStatus) { value in
         carrisNetworkController.toggleCommunityDataProviderTo(to: value)
      }
   }
   
   
   var body: some View {
      Card {
         Image(systemName: "clock.arrow.2.circlepath")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(cardColor)
         Text("ETA Provider")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(cardColor)
         Text("Select your prefered Data provider.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.label))
         Text("Ainda não faz nada.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
         providerToggle
      }
   }
   
}
