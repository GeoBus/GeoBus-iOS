//
//  GeoBusAPI.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit


struct GeoBusAPI {
  
  @Binding var vehicleAnnotations: [MapAnnotation]
//  @Binding var mapView: MKMapView
  
  @Binding var isLoading: Bool
  @Binding var isRefreshingVehicleStatuses: Bool
  @Binding var showNoVehiclesFoundAlert: Bool
  
  var routeNumber: String
  
  
  func removeAllAnnotationsFromMap() {
    OperationQueue.main.addOperation {
//      self.mapView.removeAnnotations(self.vehicleAnnotations)
      self.vehicleAnnotations.removeAll()
    }
  }
  
  
  func getVehicleStatuses() {
    
    // Do not fetch API if no route is selected
    if routeNumber.isEmpty { return }
    
    self.isLoading = true
    self.isRefreshingVehicleStatuses = false
    
    // Create a configuration
    let configuration = URLSessionConfiguration.default
    
    // Create a session
    let session = URLSession(configuration: configuration)
    
    // Setup the url
    let url = URL(string: "https://geobus-api.herokuapp.com/vehicles/" + routeNumber)!
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode == 404 {
        self.isLoading = false
        self.isRefreshingVehicleStatuses = false
        self.showNoVehiclesFoundAlert = true
        self.removeAllAnnotationsFromMap()
        return
      } else if httpResponse?.statusCode != 200 {
        self.isLoading = false
        self.isRefreshingVehicleStatuses = false
        self.removeAllAnnotationsFromMap()
        return
      }
      
      do {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([Vehicle].self, from: data!)
        
        OperationQueue.main.addOperation {
          
          self.vehicleAnnotations.removeAll()
          
          for item in decodedData {
            self.vehicleAnnotations.append(
              MapAnnotation(
                title: String(item.routeNumber ?? "-"),
                subtitle: String(item.lastStopOnVoyageName ?? "-"),
                latitude: item.lat,
                longitude: item.lng
              )
            )
          }
          
          self.isLoading = false
          self.isRefreshingVehicleStatuses = true
        }
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
}
