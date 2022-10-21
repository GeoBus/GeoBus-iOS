import Foundation


/* * */
/* MARK: - GET ELEMENT BY ID FROM ARRAY OF IDENTIFIABLES */
/* Given an array of Identifiable elements, provide a subscript */
/* for passing an ID for the element. Return the element if found, nil otherwise. */
/* Usage: let itemWithId = arrayOfIdentifiables[withId: ‹unique_id›] */

extension Array where Element: Identifiable {
   public subscript(withId id: Element.ID) -> Element? {
      first { $0.id == id }
   }
}



/* * */
/* MARK: - REMOVE DUPLICATES FOR KEY */
/* Mutate the array to remove duplicate elements that match a given key. */
/* More info here (mutating solution): https://stackoverflow.com/a/55684308 */

extension RangeReplaceableCollection {
   // Keeps only, in order, the first instances of
   // elements of the collection that compare equally for the keyPath.
   mutating func uniqueInPlace<T: Hashable>(for keyPath: KeyPath<Element, T>) {
      var unique = Set<T>()
      removeAll { !unique.insert($0[keyPath: keyPath]).inserted }
   }
}
