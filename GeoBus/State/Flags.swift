//
//  Flags.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Flags {
  
  // Continuous flags: is[DoingSomething]
  var isLoading: Bool = false
  var isRefreshingVehicleStatuses: Bool = false
  
  // Show flags: show[SomeView]
  
  var showNoVehiclesFoundAlert: Bool = false
  var showInvalidRouteAlert: Bool = false
  
  // Modification flags: [SomeObject]Changed
  var routesChanged: Bool = false
  var stopsChanged: Bool = false
  var vehiclesChanged: Bool = false
  
  let timer = Timer()
  
  // MARK: - Helper Methods
  
//  func setupResetTimer() {
//    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//      self.routesChanged = false
//      self.stopsChanged = false
//      self.vehiclesChanged = false
//    }
//  }
  
}
