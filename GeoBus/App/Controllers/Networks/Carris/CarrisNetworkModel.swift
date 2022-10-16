//
//  Routes.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//
import Foundation


/* * */
/* MARK: - CARRIS NETWORK DATA MODEL */
/* Data provided by the Carris API consists of a list of separate endpoints */
/* from which it is possible to retrieve information from routes and stops. */
/* For this app, the goal is to simplify and build upon this network model */
/* to prevent duplicated data and increase flexibility on updates to the views. */


enum Kind: Codable, Equatable {
   case tram
   case neighborhood
   case night
   case elevator
   case regular
}


enum Direction: Codable {
   case ascending
   case descending
   case circular
}


// ROUTE
// Routes are identified by its ‹routeNumber›, have a name,
// a kind (tram, nightBus, etc.) and can have several variants.
struct Route_NEW: Codable, Equatable, Identifiable {
   let id: String
   let number: String
   let name: String
   let kind: Kind
   let variants: [Variant_NEW]
   
   init(number: String, name: String, kind: Kind, variants: [Variant_NEW]) {
      self.id = number
      self.number = number
      self.name = name
      self.kind = kind
      self.variants = variants
   }
}


// VARIANT
// Variants are alternative paths the same route can have,
// like segments of a full route during peak hours.
// Variants are identified by its number inside each route,
// and they can be circular or in a straight line.
struct Variant_NEW: Codable, Equatable, Identifiable {
   let id: Int
   let number: Int
   let name: String
   let itineraries: [Itinerary_NEW]
   
   init(number: Int, name: String, itineraries: [Itinerary_NEW]) {
      self.id = number
      self.number = number
      self.name = name
      self.itineraries = itineraries
   }
}


// ITINERARY
// Itineraries hold the list of connections (stops) for each variant.
// They are identified by their direction (ascending, descending, circular).
struct Itinerary_NEW: Codable, Equatable, Identifiable {
   let id: Direction
   let direction: Direction
   let connections: [Connection_NEW]
   
   init(direction: Direction, connections: [Connection_NEW]) {
      self.id = direction
      self.direction = direction
      self.connections = connections
   }
}


// CONNECTION
// Connections are a thin wrapper before stops in order to be able
// to hold a ‹orderInRoute› number. Connections are identified by this value.
struct Connection_NEW: Codable, Equatable, Identifiable {
   let id: Int
   let orderInRoute: Int
   let stop: Stop_NEW
   
   init(orderInRoute: Int, stop: Stop_NEW) {
      self.id = orderInRoute
      self.orderInRoute = orderInRoute
      self.stop = stop
   }
}


// STOP
// Stops are identified by its ‹publicId› value.
// They have a name and a location.
struct Stop_NEW: Codable, Equatable, Identifiable {
   let id: String
   let publicId: String
   let name: String
   let lat, lng: Double
   
   init(publicId: String, name: String, lat: Double, lng: Double) {
      self.id = publicId
      self.publicId = publicId
      self.name = name
      self.lat = lat
      self.lng = lng
   }
}
