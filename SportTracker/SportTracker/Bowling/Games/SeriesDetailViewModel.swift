import Foundation
import Combine

enum SeriesDetailContentState {
    case empty
    case content([Game])
    case playing(GameViewModel)
}

class SeriesDetailViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var state: SeriesDetailContentState = .empty
    @Published var toast: Toast? = nil
    @Published var series: Series
    @Published var gameViewModel: GameViewModel?

    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(firebaseManager: FirebaseManager, series: Series) {
        self.firebaseManager = firebaseManager
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
            let gameVieModel = GameViewModel(game: currentGame)
            state = .playing(gameVieModel)
            self.gameViewModel = gameVieModel
        } else {
            state = series.games.isEmpty ? .empty : .content(games)
        }
    }

    func getCurrentGameScore() -> Int {
        series.getCurrentGameScore() ?? 0
    }
    
    /// Localy saved the current game
    private func saveCurrent(game: Game) {
        series.save(game: game)
        newGame()
    }
    
    /// Localy created new current game
    func newGame() {
        series.newGame()
        setupContent()
    }
    
    /// Save game into series on firebase
    func saveGameIntoSeries(game: Game) {
        //firebaseManager.saveGameToSeries(seriesID: <#T##String#>, game: <#T##Game#>)
    }
    
    /// Save all games in series
    func saveSeries() {
        // FIXME: seeries are saved into new object in database, it should save all games in current series, becosue self.series is using object from database, use saveGameIntoSeries and save all of them into created self.sereis
        firebaseManager.saveSeries(series)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                self?.toast = Toast(type: .success("Successfully saved in Database"))
                self?.series.currentGame = nil
                self?.setupContent()
            }.store(in: &cancellables)
    }
}
