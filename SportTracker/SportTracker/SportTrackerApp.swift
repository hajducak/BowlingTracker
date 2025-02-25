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

            let gameViewModelFactory = GameViewModelFactoryImpl()
            let seriesViewModelFactory = SeriesViewModelFactoryImpl(
                firebaseManager: firebaseManager,
                gameViewModelFactory: gameViewModelFactory
            )
            let bowlingSeriesViewModel = BowlingSeriesViewModel(
                seriesViewModelFactory: seriesViewModelFactory,
                firebaseManager: firebaseManager
            )

            ContentView(
                bowlingSeriesViewModel: bowlingSeriesViewModel
            ).preferredColorScheme(.light)
        }
    }
}
