import SwiftUI
import FirebaseCore
import SwiftData

@main
struct BowlingTrackerApp: App {
//    private var modelContainer: ModelContainer

    init() {
        FirebaseApp.configure()
//        do {
//            modelContainer = try ModelContainer(for: SportPerformance.self)
//        } catch {
//            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
//        }
    }

    var body: some Scene {
        WindowGroup {
//             let storageManager = StorageManager(modelContainer: modelContainer)
            let firebaseManager = FirebaseManager.shared

            let gameViewModelFactory = GameViewModelFactoryImpl()
            let seriesViewModelFactory = SeriesDetailViewModelFactoryImpl(
                firebaseManager: firebaseManager,
                gameViewModelFactory: gameViewModelFactory
            )
            let bowlingSeriesViewModel = SeriesViewModel(
                seriesViewModelFactory: seriesViewModelFactory,
                firebaseManager: firebaseManager
            )
            
            let statisticsViewModel = StatisticsViewModel(
                firebaseManager: firebaseManager
            )

            ContentView(
                bowlingSeriesViewModel: bowlingSeriesViewModel,
                statisticsViewModel: statisticsViewModel
            ).preferredColorScheme(.light)
        }
    }
}
