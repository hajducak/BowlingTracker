
protocol GameViewModelFactory {
    func viewModel(game: Game, user: User) -> GameViewModel
}

final class GameViewModelFactoryImpl: GameViewModelFactory {
    func viewModel(game: Game, user: User) -> GameViewModel {
        GameViewModel(game: game, user: user)
    }
}
