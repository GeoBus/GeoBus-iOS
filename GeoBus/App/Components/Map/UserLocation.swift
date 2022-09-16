//
//  UserLocation.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct UserLocation: View {

   @EnvironmentObject var mapController: MapController

   var body: some View {
      SquareButton(icon: "location.fill", size: 22)
         .onTapGesture() {
            TapticEngine.impact.feedback(.medium)
            self.mapController.centerMapOnUserLocation(andZoom: false)
         }
         .onLongPressGesture() {
            TapticEngine.impact.feedback(.medium)
            TapticEngine.impact.feedback(.medium, withDelay: 0.2)
            TapticEngine.impact.feedback(.medium, withDelay: 0.4)
            self.mapController.centerMapOnUserLocation(andZoom: true)
         }
         .alert(isPresented: $mapController.showLocationNotAllowedAlert, content: {
            Alert(
               title: Text("Allow Location Access"),
               message: Text("You have to allow location access so that GeoBus can show where you are on the map."),
               primaryButton: .cancel(),
               secondaryButton: .default(Text("Allow in Settings")) {
                  UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
               }
            )
         })
   }

}
