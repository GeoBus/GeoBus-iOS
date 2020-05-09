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
  private var endpoint = "https://carris.tecmic.com/api/v2.8/vehicleStatuses/routeNumber/"
  
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
    
    if (state == .paused || routeNumber.isEmpty) { return }
    
    self.set(state: .loading)
    
    // Setup the url
    let url = URL(string: endpoint + routeNumber)!
    
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
                lastStopInRoute: "-",
                lastGpsTime: item.lastGpsTime,
                kind: self.getKindOfVehicle(basedOn: item.routeNumber),
                latitude: item.lat,
                longitude: item.lng,
                angleInRadians: self.getAngleInRadians(
                  prevLat: item.previousLatitude ?? 0.00,
                  prevLng: item.previousLongitude ?? 0.00,
                  currLat: item.lat,
                  currLng: item.lng
                )
              )
            )
          }
          
          self.getVehiclesSGO()
          
          self.set(state: .idle)
          
        }
        
      } catch {
        print("Error info: \(error)")
        OperationQueue.main.addOperation { self.set(state: .error) }
      }
    }
    
    task.resume()
    
  }
  
  
  /* MARK: State - */
  /* * */
  
  
  
  func getKindOfVehicle(basedOn routeNumber: String) -> Vehicle.Kind {
    
    let firstLetter = routeNumber.prefix(1)
    let lastLetter = routeNumber.suffix(1)
    
    if lastLetter == "B" {
      
      return .neighborhood
      
    } else if lastLetter == "E" {
      
      if firstLetter == "5" { return .elevator }
      else { return .tram }
      
    } else if firstLetter == "2" {
      
      return .night
      
    } else {
      
      return .regular
      
    }
    
  }
  
  
  
  
  func getAngleInRadians(prevLat: Double, prevLng: Double, currLat: Double, currLng: Double) -> Double {
    // and return response to the caller
    let x = currLat - prevLat;
    let y = currLng - prevLng;
    
    var teta: Double;
    // Angle is calculated with the arctan of ( y / x )
    if (x == 0){ teta = .pi / 2 }
    else { teta = atan(y / x) }
    
    // If x is negative, then the angle is in the symetric quadrant
    if (x < 0) { teta += .pi }
    
    return teta - (.pi / 2) // Correction cuz Apple rotates clockwise
    
  }
  
  
  
  
  
  func getVehiclesSGO() {
    
    
    for vehicle in annotations {
      
      // Setup the url
      let url = URL(string: "https://carris.tecmic.com/api/v2.8/SGO/busNumber/\(vehicle.busNumber)")!
      
      // Configure a session
      let session = URLSession(configuration: URLSessionConfiguration.default)
      
      // Create the task
      let task = session.dataTask(with: url) { (data, response, error) in
        
        let httpResponse = response as? HTTPURLResponse
        
        // Check status of response
        if httpResponse?.statusCode != 200 {
          print("Error: API failed at getVehiclesSGO()")
          return
        }
        
        do {
          
          let decodedData = try JSONDecoder().decode(VehicleSGO.self, from: data!)
          
          OperationQueue.main.addOperation {
            
            vehicle.lastStopInRoute = decodedData.lastStopOnVoyageName ?? "-"
            
          }
          
        } catch {
          print("Error info: \(error)")
        }
      }
      
      task.resume()
      
    }
    
  }
  
  
}
