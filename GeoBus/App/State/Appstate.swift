//
//  Appstate.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation

class Appstate: ObservableObject {
   
   @Published var current: State = .idle
   
   enum State {
      case idle
      case loading
      case error
   }
   
   enum APIError: Error {
      case authorization
      case undefined
   }
   
   func change(to newState: State) {
      DispatchQueue.main.async {
         self.current = newState
      }
   }
   
}
