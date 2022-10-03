//
//  AboutLiveData.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct EstimationsProviderCard: View {

   @EnvironmentObject var estimationsController: EstimationsController

   private let cardColor: Color = Color(.systemTeal)

   @State var communityProviderIsOn: Bool = false


   var providerToggle: some View {
      Toggle(isOn: $communityProviderIsOn) {
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
         .onAppear() {
            if (estimationsController.estimationsProvider == .carris) {
               communityProviderIsOn = false
            } else {
               communityProviderIsOn = true
            }
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .tint(cardColor)
      .background(cardColor.opacity(0.05))
      .cornerRadius(10)
      .onChange(of: estimationsController.estimationsProvider) { value in
         if (value == .carris) {
            communityProviderIsOn = false
         } else {
            communityProviderIsOn = true
         }
      }
      .onChange(of: communityProviderIsOn) { value in
         if (value) {
            estimationsController.setProvider(selection: .community)
         } else {
            estimationsController.setProvider(selection: .carris)
         }
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
         Text("Select your prefered Time of Arrival provider.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.label))
         Text("Text about differences in provider.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
          providerToggle
      }
   }

}
