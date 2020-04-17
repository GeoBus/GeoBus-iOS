//
//  MapAnnotationsStore.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation
import Combine

class MapAnnotationsStore: ObservableObject {
  @Published var newAnnotations: [VehicleMapAnnotation] = []
  @Published var oldAnnotations: [VehicleMapAnnotation] = []
}
