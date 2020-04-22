//
//  RecentRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Route: Codable, Identifiable {
  let id = UUID()
  var routeNumber: String
  let name: String
  
  init() {
    self.routeNumber = ""
    self.name = ""
  }
  
}
