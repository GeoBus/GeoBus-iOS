//
//  UserLocation.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import SwiftUI

struct UserLocation: View {

   @ObservedObject private var mapController = MapController.shared

   var body: some View {
      SquareButton(icon: "location.fill", size: 22)
         .onTapGesture() {
            TapticEngine.impact.feedback(.medium)
            self.mapController.centerMapOnUserLocation(andZoom: false)
            Analytics.shared.capture(event: .Location_Usage_Tap)
         }
         .onLongPressGesture() {
            TapticEngine.impact.feedback(.medium)
            TapticEngine.impact.feedback(.medium, withDelay: 0.2)
            TapticEngine.impact.feedback(.medium, withDelay: 0.4)
            self.mapController.centerMapOnUserLocation(andZoom: true)
            Analytics.shared.capture(event: .Location_Usage_TapAndHold)
         }
         .alert(isPresented: $mapController.showLocationNotAllowedAlert, content: {
            Alert(
               title: Text("Allow Location Access"),
               message: Text("You have to allow location access so that GeoBus can show where you are on the map."),
               primaryButton: .cancel(),
               secondaryButton: .default(Text("Allow in Settings")) {
                  Analytics.shared.capture(event: .Location_Status_DeniedButWillOpenSettingsFromAlert)
                  UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
               }
            )
         })
   }

}
