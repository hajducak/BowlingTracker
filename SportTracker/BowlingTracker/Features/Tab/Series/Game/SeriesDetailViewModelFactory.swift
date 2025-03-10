protocol SeriesDetailViewModelFactory {
    func viewModel(series: Series) -> SeriesDetailViewModel
}

final class SeriesDetailViewModelFactoryImpl: SeriesDetailViewModelFactory {
    private let firebaseManager: FirebaseManager
    private let gameViewModelFactory: GameViewModelFactory

    init(firebaseManager: FirebaseManager, gameViewModelFactory: GameViewModelFactory) {
        self.firebaseManager = firebaseManager
        self.gameViewModelFactory = gameViewModelFactory
    }

    func viewModel(series: Series) -> SeriesDetailViewModel {
        SeriesDetailViewModel(
            firebaseManager: firebaseManager,
            gameViewModelFactory: gameViewModelFactory,
            series: series
        )
    }
}
