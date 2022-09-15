//
//  AppVersion.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//

import SwiftUI

struct AppVersion: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
   private let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"

   var body: some View {
      Text("v\(appVersion)-\(appBuild)")
         .font(Font.system(size: 10, weight: .medium, design: .default) )
         .foregroundColor(Color(.secondaryLabel))
         .padding(.vertical, 2)
         .padding(.horizontal, 7)
         .background(Color(.secondarySystemFill))
         .cornerRadius(10)
   }
}
