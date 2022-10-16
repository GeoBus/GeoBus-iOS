import Foundation

extension Array where Element: Identifiable {
   public subscript(withId id: Element.ID) -> Element? {
      first { $0.id == id }
   }
}

// Usage:
// let itemWithId = arrayOfIdentifiables[withId: ‹unique_id›]
