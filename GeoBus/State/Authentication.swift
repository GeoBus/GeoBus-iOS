//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class Authentication: ObservableObject {
  
  /* * */
  /* MARK: - Settings */
  
  private let apiKey = "ca493e56d7e1bffa1d95bf88559ef18687f987243926b0758051c2c4aba10721"
  private var endpoint = "https://gateway.carris.pt/gateway/authenticationapi/authorization/sign"
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Published Variables */
  
  @Published var authToken = ""
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Private Variables */
  
  private var refreshToken = ""
  
  /* * */
  
  
  
  
  /* * */
  /* MARK: - State */
  init() {
    
    //    statements
    
  }
  
  
  
  
  
  /* * * *
   * STATE: GET VEHICLES
   * This function calls the GeoBus API and receives vehicle metadata, including positions, for the set route number,
   * while storing them in the vehicles array. It also formats VehicleAnnotations and stores them in the annotations array.
   * It must have @objc flag because Timer is written in Objective-C.
   */
  func retrieveRefreshToken() {
    
//    // Get from iCloud
//    let iCloudKeyStore = NSUbiquitousKeyValueStore()
//    iCloudKeyStore.synchronize()
//    let savedFavorites = iCloudKeyStore.array(forKey: "favoriteRoutes") as? [String] ?? []
//
//    // Save to array
//    for routeNumber in savedFavorites {
//      let route = findRoute(from: routeNumber)
//      if route != nil {
//        self.favorites.append( route! )
//      }
//    }
    
  }
  
  /* * * *
   * FAVORITES: SAVE FAVORITE
   * This function saves a representation of the routes stored in the favorites array
   * to iCloud Key-Value-Store. This function should be called whenever a change
   * in favorites occurs, to ensure consistency across devices.
   */
  func saveRefreshToken() {
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.set(refreshToken, forKey: "refreshToken")
    iCloudKeyStore.synchronize()
  }
  
  
  
  
  /* * * *
   * STATE: GET VEHICLES
   * This function calls the GeoBus API and receives vehicle metadata, including positions, for the set route number,
   * while storing them in the vehicles array. It also formats VehicleAnnotations and stores them in the annotations array.
   * It must have @objc flag because Timer is written in Objective-C.
   */
  func authenticate() {
    
    var request = URLRequest(url: URL(string: endpoint)!)
    
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    
    var parameters: [String: Any]
    
    if (refreshToken.isEmpty) {
      parameters = [
        "token": self.apiKey,
        "type": "apikey"
      ]
    } else {
      parameters = [
        "token": self.refreshToken,
        "type": "refresh" // is this really it?
      ]
    }
    
    
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
    } catch let error {
      print(error.localizedDescription)
    }
    
    
    
    // Create the task
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at authenticate()")
        self.authenticate()
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode(Authorization.self, from: data!)
        
        OperationQueue.main.addOperation {
          
          self.authToken = decodedData.authorizationToken
          self.refreshToken = decodedData.refreshToken
          
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  /* MARK: State - */
  /* * */
  
  
}
