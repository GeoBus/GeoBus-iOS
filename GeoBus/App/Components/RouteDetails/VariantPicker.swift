//
//  RouteVariantPicker.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct VariantPicker: View {

   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared

   var body: some View {

      ScrollView(.horizontal, showsIndicators: true) {

         HStack(spacing: 10) {

            VariantWarning(qty: carrisNetworkController.activeRoute?.variants.count ?? 0)

            ForEach(carrisNetworkController.activeRoute!.variants) { variant in

               Button(action: {
                  carrisNetworkController.select(variant: variant)
               }) {
                  VariantButton(
                     variantName: variant.name,
                     isSelected: carrisNetworkController.activeVariant == variant
                  )
                  .padding(.vertical, 15)
               }
               .disabled(carrisNetworkController.activeVariant == variant)
            }

         }
         .frame(maxWidth: .infinity)
         .padding(.horizontal)

      }
   }
}
