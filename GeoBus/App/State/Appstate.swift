//
//  Appstate.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation

class Appstate: ObservableObject {
   
   @Published var global: State = .idle

   @Published var auth: State = .idle
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
            case .routes:
               self.routes = newState
            case .vehicles:
               self.vehicles = newState
            case .estimations:
               self.estimations = newState
         }
         // Change state of global module
         if (self.auth == .idle && self.routes == .idle && self.vehicles == .idle && self.estimations == .idle) {
            // All modules must be idle for global to be idle
            self.global = .idle
         } else if (self.auth == .loading || self.routes == .loading || self.vehicles == .loading || self.estimations == .loading) {
            // Global is loading if at least 1 module is loading
            self.global = .loading
         } else if (self.auth == .error || self.routes == .error || self.vehicles == .error) {
            // Global is error if at least 1 module is error (except Estimations)
            self.global = .error
         }
      }
   }
   
}
