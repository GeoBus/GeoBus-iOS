//
//  Debounce.swift
//  GeoBus
//
//  Created by @quickthyme (https://stackoverflow.com/a/59296478)
//

import Dispatch

class Debounce<T: Equatable> {
   
   private init() {}
   
   static func input(_ input: T, comparedAgainst current: @escaping @autoclosure () -> (T), perform: @escaping (T) -> ()) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
         if input == current() { perform(input) }
      }
   }
   
}
