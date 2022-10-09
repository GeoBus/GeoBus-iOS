//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {
   
   @State var route: MKPolyline?

   
   var body: some View {

      VStack(alignment: .trailing, spacing: 0) {

         ZStack(alignment: .topTrailing) {
            
            MapView(route: $route)
               .edgesIgnoringSafeArea(.vertical)
               .onAppear() {
                  self.findCoffee()
               }

            VStack(spacing: 15) {
               AboutGeoBus()
               Spacer()
               StopSearch()
               UserLocation()
            }
            .padding()

         }

         NavBar()
            .edgesIgnoringSafeArea(.vertical)
         
      }

   }

}



private extension ContentView {
   func findCoffee() {
      let start = CLLocationCoordinate2D(latitude: 37.332693, longitude: -122.03071)
      let region = MKCoordinateRegion(center: start, latitudinalMeters: 2000, longitudinalMeters: 2000)
      
      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = "coffee"
      request.region = region
      
      MKLocalSearch(request: request).start { response, error in
         guard let destination = response?.mapItems.first else { return }
         
         let request = MKDirections.Request()
         request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
         request.destination = destination
         MKDirections(request: request).calculate { directionsResponse, _ in
            self.route = directionsResponse?.routes.first?.polyline
         }
      }
   }
}
