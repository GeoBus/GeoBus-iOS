//
//  Appstate.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation


/* * */
/* MARK: - APPSTATE */
/* Appstate is a 'global' class that all controller modules use to set the current state of the app. */
/* This state is immediatly reflected on the UI to inform the user of any loading or error events. */
/* Using Appstate increases consistency in UI code and prevents direct access to controllers. */


class Appstate: ObservableObject {
   
   /* * */
   /* MARK: - SECTION 1: POSSIBLE STATE TYPES */
   /* Essentialy the app can be in either of the following three states, not simultaneously. */
   
   enum State {
      case idle
      case loading
      case error
   }
   
   
   
   /* * */
   /* MARK: - SECTION 2: MODULES */
   /* These are the modules than publish state change events. This allows the UI to provide local */
   /* loading or error messages on the relevant functionality, incresing perception of stability. */

   enum Module {
      case auth
      case stops
      case routes
      case vehicles
      case estimations
   }
   
   
   
   /* * */
   /* MARK: - SECTION 3: ERROR TYPES */
   /* Modules can publish more information on the particular error it encountered. */
   /* This functionality is planned to be expanded sometime in the future. */
   
   enum ModuleError: Error {
      
      // For Carris API
      case carris_unauthorized
      case carris_unavailable
      
      // For Community API
      case community_unavailable
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 4: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   /* Adding a private initializer is important because it stops other code from creating a new class instance. */
   
   static let shared = Appstate()
   
   private init() { }
   
   
   
   /* * */
   /* MARK: - SECTION 5: PUBLISHED VARIABLES */
   /* Here are all the @Published variables refering to the above modules that can be consumed */
   /* by the UI. It is important to keep the names of this variables short, but descriptive, */
   /* to avoid clutter on the interface code. */
   
   @Published var global: State = .idle
   
   @Published var auth: State = .idle
   @Published var stops: State = .idle
   @Published var routes: State = .idle
   @Published var vehicles: State = .idle
   @Published var estimations: State = .idle
   
   
   
   /* * */
   /* MARK: - SECTION 6: CHANGE STATE */
   /* Dispatch the change to the main queue to ensure UI updates happen smoothly and without interruptions. */
   /* After the change, follow the set rules to also update the .global state. This might change in the future. */
   
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
