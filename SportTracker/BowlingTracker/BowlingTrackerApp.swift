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
            let firebaseSeriesService = FirebaseService<Series>(collectionName: CollectionNames.series)

            let gameViewModelFactory = GameViewModelFactoryImpl()
            let seriesViewModelFactory = SeriesDetailViewModelFactoryImpl(
                firebaseService: firebaseSeriesService,
                gameViewModelFactory: gameViewModelFactory
            )
            let bowlingSeriesViewModel = SeriesViewModel(
                seriesViewModelFactory: seriesViewModelFactory,
                firebaseService: firebaseSeriesService
            )
            
            let statisticsViewModel = StatisticsViewModel(
                firebaseService: firebaseSeriesService
            )

            ContentView(
                bowlingSeriesViewModel: bowlingSeriesViewModel,
                statisticsViewModel: statisticsViewModel
            ).preferredColorScheme(.light)
        }
    }
}
