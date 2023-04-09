import Foundation


/* * */
/* MARK: - SHEET CONTROLLER */
/* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi rutrum lectus */
/* non interdum imperdiet. In hendrerit ligula velit, ac porta augue volutpat id. */


final class SheetController: ObservableObject {
   
   /* * */
   /* MARK: - 1: PRESENTABLE SHEET VIEWS */
   /* These are the available views that can be presented inside the sheet. */
   
   enum PresentableSheetView {
      case RouteSelector
      case RouteDetails
      case StopSelector
      case StopDetails
      case ConnectionDetails
      case VehicleDetails
   }
   
   
   
   /* * */
   /* MARK: - SECTION 2: PUBLISHED VARIABLES */
   /* Here are all the @Published variables refering to the above modules that can be consumed */
   /* by the UI. It is important to keep the names of this variables short, but descriptive, */
   /* to avoid clutter on the interface code. */
   
   @Published var sheetIsPresented: Bool = false
   @Published var currentlyPresentedSheetView: PresentableSheetView? = nil
   
   
   
   /* * */
   /* MARK: - 3: PRESENT SHEET */
   /* Call this function to present the view. If a sheet is already visible, */
   /* then dismiss it and after a delay present the desired sheet. */
   
   public func present(sheet: PresentableSheetView) {
      if (sheetIsPresented) {
         self.sheetIsPresented = false
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentlyPresentedSheetView = sheet
            self.sheetIsPresented = true
         }
      } else {
         self.currentlyPresentedSheetView = sheet
         self.sheetIsPresented = true
      }
   }
   
   
   
   /* * */
   /* MARK: - 4: DISMISS SHEET */
   /* Call this function to dismiss the sheet. */
   
   public func dismiss() {
      self.sheetIsPresented = false
   }
   
   
   
   /* * */
   /* MARK: - SECTION 3: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   /* Adding a private initializer is important because it stops other code from creating a new class instance. */
   
   static let shared = SheetController()
   
   private init() { }
   
   
}
