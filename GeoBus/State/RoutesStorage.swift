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
  
  /* * */
  /* MARK: - Private Variables */
  
  private var all: [Route] = []
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Published Variables */
  
  @Published var selectedRoute: Route?
  @Published var selectedVariant: RouteVariant?
  var previousSelectedVariant: RouteVariant?
  @Published var routeChanged = false
  
  @Published var stopAnnotations: [StopAnnotation] = []
  @Published var selectedStopAnnotation: StopAnnotation?
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Sets of Routes */
  
  @Published var favorites: [Route] = []
  
  @Published var trams: [Route] = []
  @Published var night: [Route] = []
  @Published var regular: [Route] = []
  @Published var neighborhood: [Route] = []
  @Published var elevators: [Route] = []
  
  /* * */
  
  
  
  
  
  /* * */
  /* MARK: - Initialization */
  
  
  /* * * *
   * INIT-
   * At initialization, routesStorage will:
   *  1. Read and parse routes.json file, and store it's content in all: [Route] variable;
   *  2. Separate routes by it's kind (like tram or night bus), and store them in their respective variables;
   *  3. Sort these just created sets of routes by route number, ascending;
   *  4. Retrieve favorites from iCloud Key-Value-Storage and store them in the favorites array.
   */
  init() {
//    self.retrieveRoutes()
//    self.separateRoutesByKind()
//    self.sortRoutes()
//    self.retrieveFavorites()
  }
  
  
  /* * * *
   * INIT: RETRIEVE ROUTES
   * This function reads the routes.json file and populates the variable all: [Route]
   */
  func retrieveRoutes() {
    if let path = Bundle.main.path(forResource: "routes", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
          let decodedData = try JSONDecoder().decode([Route].self, from: data)
        self.all.append(contentsOf: decodedData)
      } catch {
        print("Error: \(error)")
      }
    }
  }
  
  
  /* * * *
   * INIT: SEPARATE ROUTES BY KIND
   * This function separates routes by it's kind, like regular buses or trams,
   * storing them in their respective variables.
   */
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
  
  
  /* * * *
   * INIT: SORT ROUTES
   * This function sorts routes by it's route number (ascending).
   */
  func sortRoutes() {
    trams.sort(by: { $0.number < $1.number })
    night.sort(by: { $0.number < $1.number })
    neighborhood.sort(by: { $0.number < $1.number })
    elevators.sort(by: { $0.number < $1.number })
    regular.sort(by: { $0.number < $1.number })
  }
  
  
  /* * * *
   * INIT: RETRIEVE FAVORITES
   * This function retrieves favorites from iCloud Key-Value-Storage.
   */
  func retrieveFavorites() {
    
    // Get from iCloud
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.synchronize()
    let savedFavorites = iCloudKeyStore.array(forKey: "favoriteRoutes") as? [String] ?? []
    
    // Save to array
    for routeNumber in savedFavorites {
      let route = findRoute(from: routeNumber)
      if route != nil {
        self.favorites.append( route! )
      }
    }
    
  }
  
  
  /* MARK: Initialization - */
  /* * */
  
  
  
  
  
  
  
  
  
  
  
  
  /* * */
  /* MARK: - Favorites */
  
  
  /* * * *
   * FAVORITES: IS FAVORITE
   * This function checks if a route is marked as favorite.
   */
  func isFavorite(route: Route?) -> Bool {
    if route == nil { return false }
    return favorites.contains(route!)
  }
  
  
  /* * * *
   * FAVORITES: TOGGLE FAVORITE
   * This function marks a route as favorite if it is not,
   * and removes it from favorites if it is.
   */
  func toggleFavorite(route: Route?) {
    if route == nil { return }
    if let index = favorites.firstIndex(of: route!) { favorites.remove(at: index) }
    else { favorites.append(route!) }
    saveFavorites()
  }
  
  
  /* * * *
   * FAVORITES: SAVE FAVORITE
   * This function saves a representation of the routes stored in the favorites array
   * to iCloud Key-Value-Store. This function should be called whenever a change
   * in favorites occurs, to ensure consistency across devices.
   */
  func saveFavorites() {
    var favoritesToSave: [String] = []
    for favRoute in favorites {
      favoritesToSave.append(favRoute.number)
    }
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.set(favoritesToSave, forKey: "favoriteRoutes")
    iCloudKeyStore.synchronize()
  }
  
  
  /* MARK: Favorites - */
  /* * */
  
  
  
  
  
  
  
  
  
  
  
  /* * */
  /* MARK: - Routes and Variants Selection */
  
  
  /* * * *
   * SELECTION: SELECT(:Route)
   * This function sets the selectedRoute variable for the provided Route.
   * Also, it sets the default variant (the first) for the provided Route as selected,
   * as well as changed the state to .routeSelected
   */
  func select(route: Route) {
    self.selectedRoute = route
    self.select(variant: route.variants[0])
  }
  
  
  /* * * *
   * SELECTION: SELECT(:RouteVariant)
   * This function sets the provided RouteVariant as selected.
   * It also requests for a rebuild of StopAnnotations,
   * while also keeping track of the previously selected variant.
   */
  func select(variant: RouteVariant) {
    self.previousSelectedVariant = selectedVariant
    self.selectedVariant = variant
    self.selectedVariant?.ascending.sort(by: { $0.orderInRoute < $1.orderInRoute })
    self.selectedVariant?.descending.sort(by: { $0.orderInRoute < $1.orderInRoute })
    self.selectedVariant?.circular.sort(by: { $0.orderInRoute < $1.orderInRoute })
    self.stopAnnotations = formatStopAnnotations(of: self.selectedVariant!)
    self.routeChanged = true
  }
  
  
  /* * * *
   * SELECTION: SELECT(:StopAnnotation)
   * This function sets the provided StopAnnotation as selected.
   */
  func select(stop: StopAnnotation?) {
    self.selectedStopAnnotation = stop
  }
  
  
  /* * * *
   * SELECTION: SELECT(:String)
   * This function asks for the route object to the findRoute function.
   * If a route was found, it asks the select(:Route) function to set it as selected
   * and returns true to its caller. Else, it only returns false to its caller.
   */
  func select(with routeNumber: String) -> Bool {
    let route = findRoute(from: routeNumber)
    if route != nil {
      self.select(route: route!)
      return true
    } else {
      return false
    }
  }
  
  
  /* * * *
   * SELECTION: FIND ROUTE
   * This function searches for the provided routeNumber in all routes array,
   * and returns it if found. If not found, returns nil.
   */
  func findRoute(from routeNumber: String) -> Route? {
    let index = all.firstIndex(where: { (route) -> Bool in
      route.number == routeNumber // test if this is the item we're looking for
    }) ?? -1 // if the item does not exist,
    if index > 0 {
      return all[index]
    } else {
      return nil
    }
  }
  
  
  /* MARK: Routes and Variants Selection - */
  /* * */
  
  
  
  
  
  
  
  
  
  
  
  /* * */
  /* MARK: - Getters */
  
  
  /* * * *
   * GET: GET SELECTED ROUTE NUMBER
   * This function returns the selected route's number.
   */
  func getSelectedRouteNumber() -> String {
    return selectedRoute?.number ?? ""
  }
  
  
  /* * * *
   * GET: GET SELECTED VARIANT NAME
   * This function returns the selected variant's name.
   */
  func getSelectedVariantName() -> String {
    if self.selectedVariant != nil {
      return self.getVariantName(variant: self.selectedVariant!)
    } else { return "" }
  }
  
  
  /* * * *
   * GET: GET VARIANT NAME
   * This function returns the provided variant's name
   * by joining both ascending and descending variant's last stops,
   * or by providing the first stop name if it is a circular route.
   */
  func getVariantName(variant: RouteVariant) -> String {
    if variant.isCircular {
      return getTerminalStopNameForVariant(variant: variant, direction: .circular)
    }
    else {
      let firstStop = getTerminalStopNameForVariant(variant: variant, direction: .ascending)
      let lastStop = getTerminalStopNameForVariant(variant: variant, direction: .descending)
      return "\(firstStop) ⇄ \(lastStop)"
    }
  }
  
  
  /* * * *
   * GET: GET TERMINAL STOP NAME FOR SELECTED VARIANT
   * Helper function that returns the selected variant's terminal stop
   * for the provided direction.
   */
  func getTerminalStopNameForSelectedVariant(direction: Route.Direction) -> String {
    return getTerminalStopNameForVariant(variant: self.selectedVariant!, direction: direction)
  }
  
  
  /* * * *
   * GET: GET TERMINAL STOP NAME FOR VARIANT
   * This function returns the provided variant's terminal stop for the provided direction.
   */
  func getTerminalStopNameForVariant(variant: RouteVariant, direction: Route.Direction) -> String {
    switch direction {
      case .circular:
        return variant.circular.first?.name ?? "-"
      case .ascending:
        return variant.ascending.last?.name ?? (variant.descending.first?.name ?? "-")
      case .descending:
        return variant.descending.last?.name ?? (variant.ascending.first?.name ?? "-")
    }
  }
  
  
  /* MARK: Getters - */
  /* * */
  
  
  
  
  
  
  
  
  
  
  /* * */
  /* MARK: - State Checkers */
  
  
  /* * * *
   * STATE: IS ROUTE SELECTED
   * This function returns true if a route is selected, false otherwise.
   */
  func isRouteSelected() -> Bool {
    return selectedRoute != nil
  }
  
  
  /* * * *
   * STATE: IS STOP SELECTED
   * This function returns true if a route is selected, false otherwise.
   */
  func isStopSelected() -> Bool {
    return selectedStopAnnotation != nil
  }
  
  
  /* * * *
   * STATE: IS SELECTED (:RouteVariant)
   * This function returns true if the provided variant is selected, false otherwise.
   */
  func isSelected(variant: RouteVariant) -> Bool {
    return variant == self.selectedVariant
  }
  
  
  /* * * *
   * STATE: IS SELECTED VARIANT CIRCULAR
   * This function returns true if the selected variant is a circular route, false otherwise.
   */
  func isSelectedVariantCircular() -> Bool {
    if self.selectedVariant == nil { return false }
    return self.selectedVariant!.isCircular
  }
  
  
  /* MARK: State Checkers - */
  /* * */
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  /* * */
  /* MARK: - MapKit Helper Functions */
  
  
  /* * * *
   * MAP: FORMAT STOP ANNOTATIONS
   * This function returns an array of [StopAnnotation] for the provided RouteVariant.
   */
  func formatStopAnnotations(of variant: RouteVariant) -> [StopAnnotation] {
    
    var formatedAnnotations: [StopAnnotation] = []
    
    // Format ascending stops
    if variant.ascending.count > 0 {
      for stop in variant.ascending {
        formatedAnnotations.append(
          StopAnnotation(
            name: stop.name,
            publicId: stop.publicId,
            direction: .ascending,
            orderInRoute: stop.orderInRoute,
            lastStopOnVoyage: getTerminalStopNameForVariant(variant: variant, direction: .ascending),
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
            name: stop.name,
            publicId: stop.publicId,
            direction: .descending,
            orderInRoute: stop.orderInRoute,
            lastStopOnVoyage: getTerminalStopNameForVariant(variant: variant, direction: .descending),
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
            name: stop.name,
            publicId: stop.publicId,
            direction: .circular,
            orderInRoute: stop.orderInRoute,
            lastStopOnVoyage: getTerminalStopNameForVariant(variant: variant, direction: .circular),
            latitude: stop.lat,
            longitude: stop.lng
          )
        )
      }
    }
    
    return formatedAnnotations
    
  }
  
  
  
  /* MARK: MapKit Helper Functions - */
  /* * */
  
  
}
