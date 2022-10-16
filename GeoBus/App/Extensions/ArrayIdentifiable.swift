//
//  ArrayIdentifiable.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/10/2022.
//

import Foundation

extension Array where Element: Identifiable {
   public subscript(withId id: Element.ID) -> Element? {
      first { $0.id == id }
   }
}

// let arrayOfIdentifiables = []
// let itemWithId = arrayOfIdentifiables[id]
