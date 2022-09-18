//
//  Appstate.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation

class Appstate: ObservableObject {

   /* MARK: - State */
   
   @Published var global: State = .idle

   @Published var auth: State = .idle
   @Published var stops: State = .idle
   @Published var routes: State = .idle
   @Published var vehicles: State = .idle
   @Published var estimations: State = .idle
   
   enum State {
      case idle
      case loading
      case error
   }

   enum Module {
      case auth
      case stops
      case routes
      case vehicles
      case estimations
   }
   
   enum CarrisAPIError: Error {
      case unauthorized
      case unavailable
   }
   
   func change(to newState: State, for module: Module) {
      DispatchQueue.main.async {
         // Change state of affected module
         switch module {
            case .auth:
               self.auth = newState
            case .stops:
               self.stops = newState
            case .routes:
               self.routes = newState
            case .vehicles:
               self.vehicles = newState
            case .estimations:
               self.estimations = newState
         }
         // Change state of global module
         if (self.auth == .idle && self.vehicles == .idle) {
            // Only count auth and vehicles for idle global state
            self.global = .idle
         } else if (self.auth == .loading || self.vehicles == .loading) {
            // Only count auth and vehicles for loading global state
            self.global = .loading
         } else if (self.auth == .error || self.vehicles == .error) {
            // Only count auth and vehicles for error global state
            self.global = .error
         }
      }
   }
   
}
