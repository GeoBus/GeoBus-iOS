//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class VehiclesStorage: ObservableObject {
  
  // MARK: - Settings
  
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  private var syncInterval = 10.0 // seconds
  
  
  
  // MARK: - Variables
  
  var routeNumber: String = ""
  
  @Published var vehicles: [Vehicle] = []
  
  @Published var annotations: [VehicleAnnotation] = []
  
  private var timer: Timer? = nil
  
  
  
  // MARK: - State
  
  private var state = State.idle {
    // We add a property observer on 'state', which lets us
    // run a function evertyime it's value changes.
    didSet { stateDidChange() }
  }
  
  
  func set(route: String, state: State) {
    self.routeNumber = route // route must be updated first, otherwise state will update without a route being set
    self.state = state
  }
  
  func set(state: State) {
    self.routeNumber = ""
    self.state = state
  }
  
  
  func stateDidChange() {
    switch state {
      case .idle:
        timer?.invalidate()
        timer = nil
        break
      case .syncing:
        timer = Timer.scheduledTimer(
          timeInterval: syncInterval,
          target: self,
          selector: #selector(self.syncVehicles),
          userInfo: nil,
          repeats: true
        )
        self.syncVehicles()
        break
      case .error:
        break
    }
  }
  
  
  
  @objc func syncVehicles() {
    self.getVehicles()
  }
  
  
  
  /* * * *
   *
   * Get Vehicles
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  @objc func getVehicles() {
    
    if routeNumber.isEmpty { return }
    
    // Setup the url
    let url = URL(string: endpoint + "/vehicles/" + routeNumber)!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at getVehicles()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Vehicle].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.vehicles.removeAll()
          self.vehicles.append(contentsOf: decodedData)
          
          self.annotations.removeAll()
          for item in self.vehicles {
            self.annotations.append(
              VehicleAnnotation(
                routeNumber: item.routeNumber ?? "-",
                lastStopInRoute: item.lastStopOnVoyageName ?? "-",
                busNumber: String(item.busNumber),
                latitude: item.lat,
                longitude: item.lng,
                angleInRadians: item.angleInRadians
              )
            )
          }
        }
        
      } catch {
        print("Error info: \(error)")
        self.set(state: .error)
      }
    }
    
    task.resume()
    
  }
  
  
}




// MARK: - Extension for state control

extension VehiclesStorage {
  enum State {
    case idle
    case syncing
    case error
  }
}
