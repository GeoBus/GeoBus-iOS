import Boutique

extension Store where Item == RouteFinal {

   static let allRoutes = Store<RouteFinal>(
      storage: SQLiteStorageEngine.default(appendingPath: "AllRoutes")
   )

//   static let neighborhoodRoutes = Store<RouteFinal>(
//      storage: SQLiteStorageEngine.default(appendingPath: "NeighborhoodRoutes")
//   )
//
//   static let elevatorRoutes = Store<RouteFinal>(
//      storage: SQLiteStorageEngine.default(appendingPath: "ElevatorRoutes")
//   )
//
//   static let tramRoutes = Store<RouteFinal>(
//      storage: SQLiteStorageEngine.default(appendingPath: "TramRoutes")
//   )
//
//   static let nightRoutes = Store<RouteFinal>(
//      storage: SQLiteStorageEngine.default(appendingPath: "NightRoutes")
//   )
//
//   static let regularRoutes = Store<RouteFinal>(
//      storage: SQLiteStorageEngine.default(appendingPath: "RegularRoutes")
//   )

}
