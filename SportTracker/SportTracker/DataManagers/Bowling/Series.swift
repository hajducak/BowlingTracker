import Foundation

enum SeriesType: String, Codable {
    case tournament, training, league, other
}

struct Series: Codable, Identifiable {
    var id: String?
    let name: String
    let tag: SeriesType
    var games: [Game]
    var currentGame: Game

    init(id: String? = nil, name: String, tag: SeriesType, games: [Game] = [], currentGame: Game = Game()) {
        self.id = id
        self.name = name
        self.tag = tag
        self.games = games
        self.currentGame = currentGame
    }
    
    func getSeriesScore() -> Int {
        return games.reduce(0) { $0 + $1.currentScore }
    }
    
    func isCurrentGameActive() -> Bool {
        return currentGame.frames.contains { $0.frameType == .unfinished }
    }

    func getCurrentGameScore() -> Int {
        return currentGame.currentScore
    }
    
    mutating func saveCurrentGame() {
        games.append(currentGame)
    }
    
    mutating func newGame() {
        currentGame = Game()
    }
}
