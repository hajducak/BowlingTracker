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
            if let authUser = authViewModel.isAuthenticated {
                let userService = UserService(authUser: authUser)
                let gameViewModelFactory = GameViewModelFactoryImpl()
                let seriesViewModelFactory = SeriesDetailViewModelFactoryImpl(
                    userService: userService,
                    gameViewModelFactory: gameViewModelFactory
                )
                let bowlingSeriesViewModel = SeriesViewModel(
                    seriesViewModelFactory: seriesViewModelFactory,
                    userService: userService
                )
                let statisticsViewModel = StatisticsViewModel(
                    userService: userService
                )
                let userProfileViewModel = UserProfileViewModel(
                    userService: userService
                )

                ContentView(
                    bowlingSeriesViewModel: bowlingSeriesViewModel,
                    statisticsViewModel: statisticsViewModel,
                    userProfileViewModel: userProfileViewModel
                )
                .environmentObject(authViewModel)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
    }
}
