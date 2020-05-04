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
  
  private var syncInterval = 10.0 // seconds
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Published Variables */
  
  @Published var vehicles: [Vehicle] = []
  @Published var annotations: [VehicleAnnotation] = []
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Private Variables */
  
  private var timer: Timer? = nil
  
  private var routeNumber: String = ""
  
  /* * */
  
  
  
  
  init() {
    self.timer = Timer.scheduledTimer(
      timeInterval: syncInterval,
      target: self,
      selector: #selector(self.getVehicles),
      userInfo: nil,
      repeats: true
    )
  }
  
  
  
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
    case active
    case loading
    case paused
    case error
  }
  
  
  /* * * *
   * STATE: STATE VARIABLE
   * This variable holds state. When it is changed, a set of operations are performed:
   *  IDLE - Timer is invalidated. Syncing is halted.
   *  SYNCING - Timer is set. Vehicle positions are continuosly fetched from API.
   *  ERROR - An error occured while syncing. Syncing is halted and timer is invalidated.
   */
  @Published var state: State = .paused {
    // We add a property observer on 'routeNumber', which lets us
    // run a function evertyime it's value changes.
    didSet {
      switch state {
        case .idle:
          break
        case .paused:
          break
        case .active:
          self.getVehicles()
          break
        case .loading:
          break
        case .error:
          break
      }
    }
  }
  
  
  /* * * *
   * STATE: SET (:String)
   * This function sets the route number and the state variable.
   */
  func set(route: String) {
    self.routeNumber = route
  }
  
  
  /* * * *
   * STATE: SET (:State)
   * This function sets the state variable.
   */
  func set(state: State) {
    self.state = state
  }
  
  
  /* * * *
   * STATE: GET STATE
   * This function return the state variable.
   */
  func getState() -> State {
    return self.state
  }
  
  
  /* * * *
   * STATE: GET VEHICLES
   * This function calls the GeoBus API and receives vehicle metadata, including positions, for the set route number,
   * while storing them in the vehicles array. It also formats VehicleAnnotations and stores them in the annotations array.
   * It must have @objc flag because Timer is written in Objective-C.
   */
  @objc private func getVehicles() {
    
    if (state == .paused) { return }
    
    self.set(state: .loading)
    
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
        OperationQueue.main.addOperation { self.set(state: .error) }
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
          
          self.set(state: .idle)
          
        }
        
      } catch {
        print("Error info: \(error.localizedDescription)")
        OperationQueue.main.addOperation { self.set(state: .error) }
      }
    }
    
    task.resume()
    
  }
  
  
  /* MARK: State - */
  /* * */
  
  
}
