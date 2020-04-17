//
//  SelectedRoute.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct SelectedRoute {
  var routeNumber: String
  
  init() {
    self.routeNumber = ""
  }
  
  init(routeNumber: String) {
    self.routeNumber = routeNumber
  }
}
