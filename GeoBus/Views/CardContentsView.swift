//
//  CardContentsView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

struct CardContentsView: View {
  @State var routeNumber = ""
  @ObservedObject var vehicleStore: VehicleStore
  
  @Binding var vehicleAnotations: MapAnnotationsStore
  @Binding var mapWasUpdated: Bool

  
  var body: some View {
    Group {
      NavigationView {
        Form {
          Section {
            TextField("Route Number (ex. 758)", text: $routeNumber)
            Button(action: {
              self.getVehicleStatuses(route: self.routeNumber)
            }) {
              Text("Locate Nearest Buses")
            }
          }
          
          Section {
            List {
              ForEach(vehicleStore.vehicles) { index in
                RowView(vehicle: self.$vehicleStore.vehicles[index])
              }
            }
          }
        }
        .padding(.top, 15)
        .navigationBarTitle("Where is my Bus?")
      }
    }
  }
  
  
  
  
  func getVehicleStatuses(route: String) {
    
    // Create a configuration
    let configuration = URLSessionConfiguration.default
    
    // Create a session
    let session = URLSession(configuration: configuration)
    
    // Setup the url
    let url = URL(string: "https://geobus-api.herokuapp.com/vehicles/" + route)!
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
        return
      }
      
      do {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([Vehicle].self, from: data)
        
        let queue = OperationQueue.main
        queue.addOperation {
          self.vehicleStore.vehicles.removeAll();
          self.vehicleStore.vehicles.append(contentsOf: decodedData)
          
          print(self.vehicleAnotations.newAnnotations)
          
          
          
          self.vehicleAnotations.oldAnnotations.append(contentsOf: self.vehicleAnotations.newAnnotations)
            self.vehicleAnotations.newAnnotations.removeAll()
          
          
          for item in decodedData {
            self.vehicleAnotations.newAnnotations.append( VehicleMapAnnotation(title: String(item.busNumber), subtitle: item.direction, latitude: item.lat, longitude: item.lng) )
          }
          print("Request map update....")
          print(self.vehicleAnotations.newAnnotations)
          self.mapWasUpdated = true
        }
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
}
