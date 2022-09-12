//
//  About.swift
//  GeoBus
//
//  Created by João on 15/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct About: View {

   var body: some View {

      VStack(alignment: .leading, spacing: 10) {

         Text("AboutTitle")
            .font(.title)
            .fontWeight(.bold)
            .padding()

         Text("AboutParagraph")
            .padding(.horizontal)

         Text("AboutCallout")
            .fontWeight(.bold)
            .padding()

         AboutButton(icon: Image("Twitter"), text: Text("Twitter"), link: "https://twitter.com/johny________")
         AboutButton(icon: Image("GitHub"), text: Text("GitHub"), link: "https://github.com/GeoBus")
         AboutButton(icon: Image(systemName: "envelope.fill"), text: Text("Send an Email"), link: "mailto:contact@joao.earth")
         AboutButton(icon: Image(systemName: "globe"), text: Text("Visit the Website"), link: "https://joao.earth")

         AppVersion()
            .padding(.top  )

      }
      .padding(.horizontal)
      .padding(.bottom, 50)

   }
}
