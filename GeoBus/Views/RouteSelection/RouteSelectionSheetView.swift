//
//  RouteSelectionView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteSelectionSheetView: View {
  
  @Binding var selectedRoute: SelectedRoute
  @Binding var showRouteSelectionSheet: Bool
  
  var body: some View {
    NavigationView {
      Form {
        TextField("Route Number (ex. 758)", text: self.$selectedRoute.routeNumber)
        Button(action: { self.showRouteSelectionSheet = false }) { Text("Locate") }
      }
      .navigationBarTitle("Find by Route")
      .navigationBarItems(trailing: Button( action: { self.showRouteSelectionSheet = false }) { Text("Done") })
      .padding(.top, 30)
      
    }
  }
}





//    VStack {
//      Text("Find by Route")
//        .font(.largeTitle)
//        .fontWeight(.heavy)
//        .padding()
//
//      HStack {
//        TextField("Route Number (ex. 758)", text: self.$selectedRoute.routeNumber)
//          .padding(2)
//          .font(.title)
//      }
//      .padding()
//      .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
//
//      Button(action: {
//        GeoBusAPI(routeNumber: self.selectedRoute.routeNumber, vehicleLocations: self.$vehicleLocations, updateMapView: self.$updateMapView)
//          .getVehicleStatuses()
//      }) {
//        Text("Locate")
//          .font(.title)
//          .fontWeight(.heavy)
//          .padding(.all, 5)
//      }
//      .foregroundColor(Color.white)
//      .padding()
//      .background(Color.blue)
//      .cornerRadius(15)


//      Spacer()

//    .padding()


