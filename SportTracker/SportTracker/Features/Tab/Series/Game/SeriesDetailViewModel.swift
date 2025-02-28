import Foundation
import Combine

enum SeriesDetailContentState {
    case empty
    case content([Game])
    case playing(GameViewModel)
}

class SeriesDetailViewModel: ObservableObject, Identifiable {
    @Published var games: [Game] = []
    @Published var state: SeriesDetailContentState = .empty
    @Published var toast: Toast? = nil
    @Published var series: Series
    @Published var gameViewModel: GameViewModel?
    @Published var shouldDismiss: Bool = false
    @Published var savingIsLoading: Bool = false

    private let gameViewModelFactory: GameViewModelFactory
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []
    
    let seriesSaved = PassthroughSubject<Series, Never>()

    init(firebaseManager: FirebaseManager, gameViewModelFactory: GameViewModelFactory, series: Series) {
        self.firebaseManager = firebaseManager
        self.gameViewModelFactory = gameViewModelFactory
        self.series = series
        self.games = series.games
        setupContent()

        $gameViewModel
            .compactMap { $0 }
            .flatMap { $0.gameSaved }
            .sink { [weak self] savedGame in
                self?.saveCurrent(game: savedGame)
            }
            .store(in: &cancellables)
    }

    func setupContent() {
        if series.isCurrentGameActive() {
            guard let currentGame = series.currentGame else {
                state = series.games.isEmpty ? .empty : .content(games)
                return
            }
            let viewModel = gameViewModelFactory.viewModel(game: currentGame)
            self.gameViewModel = viewModel
            state = .playing(viewModel)
        } else {
            state = series.games.isEmpty ? .empty : .content(games)
        }
    }

    func getCurrentGameScore() -> Int {
        series.getCurrentGameScore() ?? 0
    }
    
    /// Locally saves the current game
    private func saveCurrent(game: Game) {
        saveGameIntoSeries(game: game)
    }
    
    /// Creates a new current game locally
    func newGame() {
        series.newGame()
        setupContent()
    }

    /// Saves the game to Firebase and updates the local series data
    func saveGameIntoSeries(game: Game) {
        savingIsLoading = true
        firebaseManager.saveGameToSeries(seriesID: series.id, game: game)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.toast = Toast(type: .success("Successfully saved in Database"))
                }
                self.newGame()
                self.fetchUpdatedSeries()
            }
            .store(in: &cancellables)
    }
    
    /// Fetches the updated series from Firebase
    private func fetchUpdatedSeries() {
        firebaseManager.fetchAllSeries()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] allSeries in
                guard let self, let updatedSeries = allSeries.first(where: { $0.id == self.series.id }) else { return }
                self.series = updatedSeries
                self.savingIsLoading = false
            }
            .store(in: &cancellables)
    }
    
    /// Saves the entire series and ensures `BowlingSeriesViewModel` updates the UI
    func saveSeries() {
        guard !series.games.isEmpty else {
            toast = Toast(type: .error(.customError("No games in series to save")))
            return
        }
        save()
    }
    
    func save() {
        series.currentGame = nil
        firebaseManager.saveSeries(series)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                toast = Toast(type: .success("Series successfully saved"))
                seriesSaved.send(self.series)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.shouldDismiss = true
                }
            }
            .store(in: &cancellables)
    }
}
