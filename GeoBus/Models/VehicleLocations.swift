//
//  VehicleLocations.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation
import Combine

class VehicleLocations: ObservableObject {
  @Published var annotations: [VehicleMapAnnotation] = []
}
