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
  
  /* * */
  /* MARK: - Settings */
  
  private var syncInterval = 5.0 // seconds
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Private Variables */
  
  private var routeNumber: String = ""
  private var timer: Timer? = nil
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Published Variables */
  
  @Published var vehicles: [Vehicle] = []
  @Published var annotations: [VehicleAnnotation] = []
  
  /* * */
  
  
  
  
  
  
  /* * */
  /* MARK: - State */
  
  
  /* * * *
   * STATE: ENUMERATION FOR STATE CONTROL
   * There are three possible states for vehicles storage.
   *  IDLE - Module is paused. Nothing is happening;
   *  SYNCING - Module fetches vehicle positions acording to the set syncInterval;
   *  ERROR - Module encountered an error while syncing.
   */
  enum State {
    case idle
    case syncing
    case error
  }
  
  
  /* * * *
   * STATE: STATE VARIABLE
   * This variable holds state. When it is changed, a set of operations are performed:
   *  IDLE - Timer is invalidated. Syncing is halted.
   *  SYNCING - Timer is set. Vehicle positions are continuosly fetched from API.
   *  ERROR - An error occured while syncing. Syncing is halted and timer is invalidated.
   */
  private var state = State.idle {
    // We add a property observer on 'state', which lets us
    // run a function evertyime it's value changes.
    didSet {
      switch state {
        case .idle:
          self.timer?.invalidate()
          self.timer = nil
          break
        case .syncing:
          self.getVehicles()
          self.timer = Timer.scheduledTimer(
            timeInterval: syncInterval,
            target: self,
            selector: #selector(self.getVehicles),
            userInfo: nil,
            repeats: true
          )
          break
        case .error:
          self.timer?.invalidate()
          self.timer = nil
          break
      }
    }
  }
  
  
  /* * * *
   * STATE: SET
   * This function sets the route number and the state variable.
   */
  func set(route: String, state: State) {
    self.routeNumber = route // route must be updated first, otherwise state will update without a route being set
    self.state = state
  }
  
  
  /* * * *
   * STATE: SET (:State)
   * This function sets the state variable.
   */
  func set(state: State) {
    self.routeNumber = ""
    self.state = state
  }
  
  
  /* * * *
   * STATE: GET VEHICLES
   * This function calls the GeoBus API and receives vehicle metadata, including positions, for the set route number,
   * while storing them in the vehicles array. It also formats VehicleAnnotations and stores them in the annotations array.
   * It must have @objc flag because Timer is written in Objective-C.
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
                busNumber: String(item.busNumber),
                routeNumber: item.routeNumber,
                lastStopInRoute: item.lastStopOnVoyageName ?? "-",
                kind: item.kind,
                latitude: item.lat,
                longitude: item.lng,
                angleInRadians: item.angleInRadians
              )
            )
          }
          
        }
        
      } catch {
        print("Error info: \(error.localizedDescription)")
        self.set(state: .error)
      }
    }
    
    task.resume()
    
  }
  
  
  /* MARK: State - */
  /* * */
  
  
}
