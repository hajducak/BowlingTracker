protocol SeriesDetailViewModelFactory {
    func viewModel(series: Series) -> SeriesDetailViewModel
}

final class SeriesDetailViewModelFactoryImpl: SeriesDetailViewModelFactory {
    private let userService: UserService
    private let gameViewModelFactory: GameViewModelFactory

    init(userService: UserService, gameViewModelFactory: GameViewModelFactory) {
        self.userService = userService
        self.gameViewModelFactory = gameViewModelFactory
    }

    func viewModel(series: Series) -> SeriesDetailViewModel {
        SeriesDetailViewModel(
            userService: userService,
            gameViewModelFactory: gameViewModelFactory,
            series: series
        )
    }
}
