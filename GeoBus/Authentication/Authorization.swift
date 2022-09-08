//
//  Authorization.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Authorization: Codable, Equatable {

   var authorizationToken: String = ""
   var refreshToken: String = ""
   var expires: Double = 0

   mutating func clear() {
      self.authorizationToken = ""
      self.refreshToken = ""
      self.expires = 0
   }

   func isValid() -> Bool {
      return !(authorizationToken.isEmpty)
   }

}
