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
            let performanceListViewModel = PerformanceListViewModel(storageManager: storageManager, firebaseManager: firebaseManager)
            let addPerformanceViewModel = AddPerformanceViewModel(storageManager: storageManager, firebaseManager: firebaseManager)
            let bowlingSeriesViewModel = BowlingSeriesViewModel(firebaseManager: firebaseManager)

            ContentView(
                addPerformanceViewModel: addPerformanceViewModel,
                performanceListViewModel: performanceListViewModel,
                bowlingSeriesViewModel: bowlingSeriesViewModel
            )
        }
    }
}
