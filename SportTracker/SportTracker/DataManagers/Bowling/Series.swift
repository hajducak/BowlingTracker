import Foundation

enum SeriesType {
    case tournament, training, league, other
}

struct Series {
    let name: String
    let tag: SeriesType
    let date: Date
    var games: [Game]
    var currentGame: Game

    init(name: String, tag: SeriesType, date: Date = Date.now, games: [Game] = [], currentGame: Game = Game()) {
        self.name = name
        self.tag = tag
        self.date = date
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
