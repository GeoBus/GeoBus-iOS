//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class RoutesStorage: ObservableObject {
  
  @Published var selectedRoute: Route?
  @Published var selectedVariant: RouteVariant?
  
  @Published var favorites: [Route] = []
  
  @Published var recent: [Route] = []
  
  @Published var all: [Route] = []
  
  
  @Published var stopAnnotations: [StopAnnotation] = []
  
  
  @Published var isLoading: Bool = false
  
  
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  
  // ----------------------------
  
  init() {
    self.syncAllRoutes()
  }
  
  
  /* * * *
   *
   * Get Routes
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  private func syncAllRoutes() {
    
    self.isLoading = true
    
    // Setup the url
    let url = URL(string: endpoint + "/routes/")!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at getRoutes()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Route].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.all.append(contentsOf: decodedData)
          self.retrieveFavorites()
          self.isLoading = false
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  func formatStopAnnotations(of variant: RouteVariant) -> [StopAnnotation] {
    
    var formatedAnnotations: [StopAnnotation] = []
    
    // Format ascending stops
    if variant.ascending.count > 0 {
      for stop in variant.ascending {
        formatedAnnotations.append(
          StopAnnotation(
            title: String(stop.name),
            subtitle: stop.orderInRoute != nil ? String(stop.orderInRoute!) : "-",
            latitude: stop.lat,
            longitude: stop.lng
          )
        )
      }
    }
    
    // Format descending stops
    if variant.descending.count > 0 {
      for stop in variant.descending {
        formatedAnnotations.append(
          StopAnnotation(
            title: String(stop.name),
            subtitle: stop.orderInRoute != nil ? String(stop.orderInRoute!) : "-",
            latitude: stop.lat,
            longitude: stop.lng
          )
        )
      }
    }
    
    // Format circular stops
    if variant.circular.count > 0 {
      for stop in variant.circular {
        formatedAnnotations.append(
          StopAnnotation(
            title: String(stop.name),
            subtitle: stop.orderInRoute != nil ? String(stop.orderInRoute!) : "-",
            latitude: stop.lat,
            longitude: stop.lng
          )
        )
      }
    }
    
    return formatedAnnotations
    
  }
  
  
  
  
  func isSelected() -> Bool {
    return selectedRoute != nil
  }
  
  func isThisVariantSelected(variant: RouteVariant) -> Bool {
    return variant == self.selectedVariant
  }
  
  func getVariantName(variant: RouteVariant) -> String {
    if variant.isCircular {
      
      return "\(variant.circular.first?.name ?? "-")"
      
    } else {
      
      let firstStop = getTerminalStopNameForVariant(variant: variant, direction: .ascending)
      let lastStop = getTerminalStopNameForVariant(variant: variant, direction: .descending)
      
      return "\(firstStop) ⇄ \(lastStop)"
      
    }
  }
  
  
  
  func getTerminalStopNameForSelectedVariant(direction: RouteDirection) -> String {
    return getTerminalStopNameForVariant(variant: self.selectedVariant!, direction: direction)
  }
  
  
  func getTerminalStopNameForVariant(variant: RouteVariant, direction: RouteDirection) -> String {
    switch direction {
      
      case .ascending:
        return variant.ascending.last?.name ?? (variant.descending.first?.name ?? "-")
      
      case .descending:
        return variant.descending.last?.name ?? (variant.ascending.first?.name ?? "-")
      
      case .circular:
        return ""
    }
  }
  
  
  
  
  
  
  
  func getRoute(from routeNumber: String) -> Route? {
    let index = all.firstIndex(where: { (route) -> Bool in
      route.number == routeNumber // test if this is the item you're looking for
    }) ?? -1 // if the item does not exist,
    if index > 0 {
      return all[index]
    } else {
      return nil
    }
  }
  
  
  
  
  func select(route: Route) {
    self.selectedRoute = route
    self.selectedVariant = route.variants[0]
    self.stopAnnotations = formatStopAnnotations(of: self.selectedVariant!)
  }
  
  func select(variant: RouteVariant) {
    self.selectedVariant = variant
    self.stopAnnotations = formatStopAnnotations(of: self.selectedVariant!)
  }
  
  func select(with routeNumber: String) {
    self.selectedRoute = getRoute(from: routeNumber)
  }
  
  
  
  
  
  // ----------- FAVORITES -------------------
  
  
  func isFavorite(route: Route?) -> Bool {
    if route == nil { return false }
    return favorites.contains(route!)
  }
  
  
  func toggleFavorite(route: Route?) {
    if route == nil { return }
    if let index = favorites.firstIndex(of: route!) {
      favorites.remove(at: index)
    } else {
      favorites.append(route!)
    }
    saveFavorites()
  }
  
  
  
  
  
  
  // iCloud Storage for Favorites
  
  
  func saveFavorites() {
    var favoritesToSave: [String] = []
    
    for favRoute in favorites {
      favoritesToSave.append(favRoute.number)
    }
    
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.set(favoritesToSave, forKey: "favoriteRoutes")
    iCloudKeyStore.synchronize()
  }
  
  
  func retrieveFavorites() {
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.synchronize()
    let savedFavorites = iCloudKeyStore.array(forKey: "favoriteRoutes") as? [String] ?? []
    
    for routeNumber in savedFavorites {
      let route = getRoute(from: routeNumber)
      if route != nil {
        self.favorites.append( route! )
      }
    }
    
  }
  
  
  
}



// MARK: - Extension for state control

extension RoutesStorage {
  enum RouteDirection {
    case ascending
    case descending
    case circular
  }
}
