//
//  RouteVariantPicker.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct VariantPicker: View {

   @EnvironmentObject var carrisNetworkController: CarrisNetworkController

   var body: some View {

      ScrollView(.horizontal, showsIndicators: true) {

         HStack(spacing: 10) {

            VariantWarning(qty: carrisNetworkController.selectedRoute?.variants.count ?? 0)

            ForEach(carrisNetworkController.selectedRoute!.variants) { variant in

               Button(action: {
                  carrisNetworkController.select(variant: variant)
               }) {
                  VariantButton(
                     variantName: variant.name,
                     isSelected: carrisNetworkController.selectedVariant == variant
                  )
                  .padding(.vertical, 15)
               }
               .disabled(carrisNetworkController.selectedVariant == variant)
            }

         }
         .frame(maxWidth: .infinity)
         .padding(.horizontal)

      }
   }
}
