//
//  RecentRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct RouteVariant: Codable, Identifiable, Equatable {
  var id = UUID()
  let number: Int
  let isCircular: Bool
  var ascending: [Stop] = []
  var descending: [Stop] = []
  var circular: [Stop] = []
  
}
