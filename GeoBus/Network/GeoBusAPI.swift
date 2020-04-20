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
  
  @Binding var selectedRoute: Route
  
  @Binding var availableRoutes: AvailableRoutes
  @Binding var annotationsStore: AnnotationsStore
  
  @Binding var isLoading: Bool
  @Binding var isAutoUpdating: Bool
  
  
  private let apiEndpoint = "https://geobus-api.herokuapp.com"
  
  
  
  
  /* * *
   * getRoutes()
   */
  func getRoutes() {
    
    if availableRoutes.all.count > 0 {
      return
    }
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Setup the url
    let url = URL(string: apiEndpoint + "/routes/")!
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        self.isLoading = false
        print("Error: API failed at getRoutes()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Route].self, from: data!)
        
        OperationQueue.main.addOperation {
          for item in decodedData {
            self.availableRoutes.all.append(item)
          }
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  
  
  
  
  
  
  
  /* * *
   * getStops()
   */
  func getStops() {
    
    // Do not fetch API if no route is selected
    if selectedRoute.routeNumber.isEmpty {
      isLoading = false
      annotationsStore.stops.removeAll()
      return
    }
    
    isLoading = true
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Setup the url
    let url = URL(string: apiEndpoint + "/stops/" + selectedRoute.routeNumber)!
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        self.isLoading = false
        self.annotationsStore.stops.removeAll()
        print("Error: API failed at getStops()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Stop].self, from: data!)
        
        OperationQueue.main.addOperation {
          
          self.annotationsStore.stops.removeAll()
          
          for item in decodedData {
            self.annotationsStore.stops.append(
              StopAnnotation(
                title: String(item.name ?? "-"),
                subtitle: String(item.publicId ?? "-"),
                latitude: item.lat,
                longitude: item.lng
              )
            )
          }
          
          self.isLoading = false
          
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  
  
  /* * *
   * getVehicles()
   */
  func getVehicles() {
    
    // Do not fetch API if no route is selected
    if selectedRoute.routeNumber.isEmpty {
      self.isLoading = false
      self.isAutoUpdating = false
      self.annotationsStore.vehicles.removeAll()
      return
    }
    
    self.isLoading = true
    self.isAutoUpdating = false
    
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Setup the url
    let url = URL(string: apiEndpoint + "/vehicles/" + selectedRoute.routeNumber)!
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        self.isLoading = false
        self.isAutoUpdating = false
        self.annotationsStore.vehicles.removeAll()
        print("Error: API failed at getVehicles()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Vehicle].self, from: data!)
        
        OperationQueue.main.addOperation {
          
          self.annotationsStore.vehicles.removeAll()
          
          for item in decodedData {
            self.annotationsStore.vehicles.append(
              VehicleAnnotation(
                title: String(item.routeNumber ?? "-"),
                subtitle: String(item.lastStopOnVoyageName ?? "-"),
                latitude: item.lat,
                longitude: item.lng
              )
            )
          }
          
          self.isLoading = false
          self.isAutoUpdating = true
          
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  
}
