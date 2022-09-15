//
//  RouteVariantPicker.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct VariantPicker: View {

   @EnvironmentObject var routesController: RoutesController

   var body: some View {

      ScrollView(.horizontal, showsIndicators: true) {

         HStack(spacing: 10) {

            VariantWarning(qty: routesController.selectedRoute?.variants.count ?? 0)

            ForEach(routesController.selectedRoute!.variants) { variant in

               Button(action: {
                  self.routesController.select(variant: variant)
               }) {
                  VariantButton(
                     variantName: variant.name,
                     isSelected: routesController.selectedVariant == variant
                  )
               }
               .disabled(routesController.selectedVariant == variant)
            }

         }
         .frame(maxWidth: .infinity)
         .padding(.horizontal)

      }
   }
}






//VStack {
//  ForEach(stopsStorage.stops) { stop in
//    VStack(alignment: .leading) {
//      StopButton(stop: stop)
//        .padding(.bottom)
//      //              VerticalLine(thickness: 2, color: .yellow)
//    }
//    .padding(.horizontal)
//  }
//}
