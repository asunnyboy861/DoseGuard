import SwiftUI
import CoreData

@main
struct DoseGuardApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
