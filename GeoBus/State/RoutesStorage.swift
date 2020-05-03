//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class RoutesStorage: ObservableObject {
  
  // MARK: - Settings
  
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  
  
  // MARK: - Variables
  
  private var all: [Route] = []
  
  @Published var selectedRoute: Route?
  @Published var selectedVariant: RouteVariant?
  var previousSelectedVariant: RouteVariant?
  
  @Published var selectedStopAnnotation: StopAnnotation?
  @Published var isStopSelected: Bool = false
  
  @Published var favorites: [Route] = []
  
  @Published var trams: [Route] = []
  @Published var night: [Route] = []
  @Published var regular: [Route] = []
  @Published var neighborhood: [Route] = []
  @Published var elevators: [Route] = []
  
  
  @Published var stopAnnotations: [StopAnnotation] = []
  
  
  
  // MARK: - State
  
  @Published var state = State.idle {
    // We add a property observer on 'state', which lets us
    // run a function evertyime it's value changes.
    didSet { stateDidChange() }
  }
  
  
  func set(state: State) {
    self.state = state
  }
  
  
  func stateDidChange() {
    switch state {
      case .idle:
        break
      case .syncing:
        self.syncAllRoutes()
        break
      case .routeChanged:
        break
      case .routeSelected:
        break
      case .error:
        break
    }
  }
  
  
  
  
  
  // MARK: - Initialization
  
  init() {
    self.set(state: .syncing)
  }
  
  
  
  // MARK: - Network Calls
  
  /* * * *
   *
   * Get Routes
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  private func syncAllRoutes() {
    
    // Setup the url
    let url = URL(string: endpoint + "/routes/")!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at syncAllRoutes()")
        OperationQueue.main.addOperation { self.set(state: .error) }
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Route].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.all.append(contentsOf: decodedData)
          self.separateRoutesByKind()
          self.sortRoutes()
          self.retrieveFavorites()
          self.set(state: .idle)
        }
        
      } catch {
        print("Error info: \(error.localizedDescription)")
        OperationQueue.main.addOperation { self.set(state: .error) }
      }
    }
    
    task.resume()
    
  }
  
  
  
  
  func separateRoutesByKind() {
    
    for route in all {
      switch route.kind {
        case "tram":
          trams.append(route)
          break
        case "night":
          night.append(route)
          break
        case "neighborhood":
          neighborhood.append(route)
          break
        case "elevator":
          elevators.append(route)
          break
        default: // kind == "regular"
          regular.append(route)
          break
      }
    }
    
  }
  
  
  func sortRoutes() {
    trams.sort(by: { $0.number < $1.number })
    night.sort(by: { $0.number < $1.number })
    neighborhood.sort(by: { $0.number < $1.number })
    elevators.sort(by: { $0.number < $1.number })
    regular.sort(by: { $0.number < $1.number })
  }
  
  
  
  
  
  
  
  
  
  func formatStopAnnotations(of variant: RouteVariant) -> [StopAnnotation] {
    
    var formatedAnnotations: [StopAnnotation] = []
    
    // Format ascending stops
    if variant.ascending.count > 0 {
      for stop in variant.ascending {
        formatedAnnotations.append(
          StopAnnotation(
            name: String(stop.name),
            publicId: String(stop.publicId),
            direction: .ascending,
            orderInRoute: stop.orderInRoute ?? -1,
            lastStopOnVoyage: variant.ascending.last?.name ?? "-",
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
            name: String(stop.name),
            publicId: String(stop.publicId),
            direction: .descending,
            orderInRoute: stop.orderInRoute ?? -1,
            lastStopOnVoyage: variant.descending.last?.name ?? "-",
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
            name: String(stop.name),
            publicId: String(stop.publicId),
            direction: .circular,
            orderInRoute: stop.orderInRoute ?? -1,
            lastStopOnVoyage: variant.circular.last?.name ?? "-",
            latitude: stop.lat,
            longitude: stop.lng
          )
        )
      }
    }
    
    return formatedAnnotations
    
  }
  
  
  
  
  
  func getSelectedRouteNumber() -> String {
    return selectedRoute?.number ?? ""
  }
  
  
  func isSelected() -> Bool {
    return selectedRoute != nil
  }
  
  func isThisVariantSelected(variant: RouteVariant) -> Bool {
    return variant == self.selectedVariant
  }
  
  func getSelectedVariantName() -> String {
    if self.selectedVariant != nil {
      return self.getVariantName(variant: self.selectedVariant!)
    } else { return "" }
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
    self.select(variant: route.variants[0])
    self.set(state: .routeSelected)
  }
  
  func select(with routeNumber: String) -> Bool {
    let route = getRoute(from: routeNumber)
    if route != nil {
      self.select(route: route!)
      return true
    } else {
      return false
    }
  }
  
  func select(variant: RouteVariant) {
    self.selectedVariant = variant
    self.stopAnnotations = formatStopAnnotations(of: self.selectedVariant!)
  }
  
  
  
  
  
  func setSelectedStopPublicId(annotation: StopAnnotation) {
    self.selectedStopAnnotation = annotation
    self.isStopSelected = true
  }
  
  func unselectStop() {
    self.selectedStopAnnotation = nil
    self.isStopSelected = false
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
  
  enum State {
    case idle
    case syncing
    case routeChanged
    case routeSelected
    case error
  }
  
  enum RouteDirection {
    case ascending
    case descending
    case circular
  }
  
}







// PARSE JSON FILE
//
// if let path = Bundle.main.path(forResource: "test", ofType: "json") {
//    do {
//          let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//          let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//          if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
//                    // do stuff
//          }
//      } catch {
//           // handle error
//      }
// }
