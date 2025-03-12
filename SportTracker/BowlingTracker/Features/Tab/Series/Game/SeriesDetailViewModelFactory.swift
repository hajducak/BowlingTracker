protocol SeriesDetailViewModelFactory {
    func viewModel(series: Series) -> SeriesDetailViewModel
}

final class SeriesDetailViewModelFactoryImpl: SeriesDetailViewModelFactory {
    private let firebaseService: FirebaseService<Series>
    private let gameViewModelFactory: GameViewModelFactory

    init(firebaseService: FirebaseService<Series>, gameViewModelFactory: GameViewModelFactory) {
        self.firebaseService = firebaseService
        self.gameViewModelFactory = gameViewModelFactory
    }

    func viewModel(series: Series) -> SeriesDetailViewModel {
        SeriesDetailViewModel(
            firebaseService: firebaseService,
            gameViewModelFactory: gameViewModelFactory,
            series: series
        )
    }
}
