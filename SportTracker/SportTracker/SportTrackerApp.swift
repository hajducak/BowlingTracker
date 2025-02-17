import SwiftUI
import FirebaseCore
import SwiftData

@main
struct SportTrackerApp: App {
    private var modelContainer: ModelContainer

    init() {
        FirebaseApp.configure()

        do {
            modelContainer = try ModelContainer(for: SportPerformance.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            let storageManager = StorageManager(modelContainer: modelContainer)
            let firebaseManager = FirebaseManager.shared
            let viewModel = SportPerformanceViewModel(storageManager: storageManager, firebaseManager: firebaseManager)

            ContentView(viewModel: viewModel)
        }
    }
}
