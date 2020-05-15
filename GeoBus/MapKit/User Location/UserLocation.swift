//
//  CenterUserLocation.swift
//  GeoBus
//
//  Created by João on 15/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import MapKit

struct UserLocation: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  @Binding var mapView: MKMapView
  
  private let locationManager = CLLocationManager()
  
  @State var showLocationNotAllowedAlert = false
  
  
  var body: some View {
    VStack {
      Spacer()
      Button(action: {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
          let userLocation = self.mapView.userLocation
          self.mapView.setCenter(userLocation.coordinate, animated: true)
        } else if CLLocationManager.authorizationStatus() != .notDetermined {
          self.showLocationNotAllowedAlert = true
        }
      }) {
        VStack {
          Image(systemName: "location.fill")
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray5) : Color(.white))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding()
      }
      .alert(isPresented: $showLocationNotAllowedAlert, content: {
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
  
}
