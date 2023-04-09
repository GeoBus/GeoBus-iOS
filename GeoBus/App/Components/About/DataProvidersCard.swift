//
//  AboutLiveData.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 19/09/2022.
//

import SwiftUI

struct DataProvidersCard: View {
   
   private let accentColor: Color = Color(.systemTeal)
   
   var body: some View {
      Card {
         Image(systemName: "clock.arrow.2.circlepath")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(accentColor)
         Text("Community Data")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(accentColor)
         Text("Try an experimental feature made in partnership with people interested in improving transportation in Lisbon.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.label))
         Text("This includes better arrival time estimates for all stops, more precise vehicle locations and additional route information.")
            .multilineTextAlignment(.center)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(.secondaryLabel))
         CommunityProviderToggle()
      }
   }
   
}



struct CommunityProviderToggle: View {
   
   private let accentColor: Color = Color(.systemTeal)
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      Toggle(isOn: $carrisNetworkController.communityDataProviderStatus) {
         HStack {
            Image(systemName: "staroflife.circle")
               .renderingMode(.template)
               .font(Font.system(size: 25))
               .foregroundColor(accentColor)
            Text("Community Data")
               .font(Font.system(size: 18, weight: .bold))
               .foregroundColor(accentColor)
               .padding(.leading, 5)
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .tint(accentColor)
      .background(accentColor.opacity(0.05))
      .cornerRadius(10)
      .onChange(of: carrisNetworkController.communityDataProviderStatus) { value in
         carrisNetworkController.toggleCommunityDataProviderStatus(to: value)
      }
   }
   
}
