
protocol GameViewModelFactory {
    func viewModel(game: Game) -> GameViewModel
}

final class GameViewModelFactoryImpl: GameViewModelFactory {
    func viewModel(game: Game) -> GameViewModel {
        GameViewModel(game: game)
    }
}
