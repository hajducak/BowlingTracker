import SwiftUI
import FirebaseCore
import SwiftData

@main
struct BowlingTrackerApp: App {
    @StateObject private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        let authService = AuthService()
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
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
                )
                .preferredColorScheme(.light)
                .environmentObject(authViewModel)
            } else {
                AuthView(viewModel: authViewModel)
                    .preferredColorScheme(.light)
            }
        }
    }
}
