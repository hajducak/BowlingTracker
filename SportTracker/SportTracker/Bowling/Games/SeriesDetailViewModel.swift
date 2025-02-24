import Foundation
import Combine

enum SeriesDetailContentState {
    case empty
    case content([Game])
    case playing(Game)
}

class SeriesDetailViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var state: SeriesDetailContentState = .empty
    @Published var toast: Toast? = nil
    @Published var series: Series

    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(firebaseManager: FirebaseManager, series: Series) {
        self.firebaseManager = firebaseManager
        self.series = series
        self.games = series.games
        setupContent()
    }

    func setupContent() {
        if series.isCurrentGameActive() {
            guard let currentGame = series.currentGame else {
                state = series.games.isEmpty ? .empty : .content(games)
                return
            }
            state = .playing(currentGame)
        } else {
            state = series.games.isEmpty ? .empty : .content(games)
        }
    }

    func getCurrentGameScore() -> Int {
        series.getCurrentGameScore() ?? 0
    }
    
    /// Localy saved the current game
    func saveCurrent(game: Game) {
        series.saveCurrentGame()
    }
    
    /// Localy created new current game
    func newGame() {
        series.newGame()
    }
    
    /// Save game into series on firebase
    func saveSeries() {
        // firebaseManager.saveGameToSeries(seriesID: <#T##String#>, game: <#T##Game#>)
    }
}
