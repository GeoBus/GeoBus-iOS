import Boutique

extension Store where Item == Vehicle {

   static let vehiclesStore = Store<Vehicle>(
      storage: SQLiteStorageEngine.default(appendingPath: "Vehicles")
   )

}
