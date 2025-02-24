import Foundation

enum SeriesType: String, Codable {
    case tournament, training, league, other
}

struct Series: Codable, Identifiable {
    var id: String?
    var date: Date
    let name: String
    let tag: SeriesType
    var games: [Game]
    var currentGame: Game?

    init(id: String? = nil, date: Date = Date.now, name: String, tag: SeriesType, games: [Game] = [], currentGame: Game? = Game()) {
        self.id = id
        self.date = date
        self.name = name
        self.tag = tag
        self.games = games
        self.currentGame = currentGame
    }
    
    func getSeriesScore() -> Int {
        return games.reduce(0) { $0 + $1.currentScore }
    }

    func getSeriesAvarage() -> Double {
        guard getSeriesScore() != 0, games.count != 0 else { return 0 }
        return Double(getSeriesScore() / games.count)
    }
    
    func getSeriesStrikePercentage() -> Double {
        let normalFrames = games.count * 9
        let totalStrikes = games.reduce(0) { $0 + $1.strikeCount }
        
        let extraFrames = games.reduce(0) { $0 + $1.lastFrameCount().strikes + $1.lastFrameCount().spares + $1.lastFrameCount().opens }
        let totalFramesPlusExtraRolls = normalFrames + extraFrames

        return totalFramesPlusExtraRolls > 0 ? (Double(totalStrikes) / Double(totalFramesPlusExtraRolls) * 100).rounded(toPlaces: 2) : 0.0
    }

    func getSeriesSparePercentage() -> Double {
        let normalFrames = games.count * 9
        let totalSpares = games.reduce(0) { $0 + $1.spareCount }
        
        let extraFrames = games.reduce(0) { $0 + $1.lastFrameCount().strikes + $1.lastFrameCount().spares + $1.lastFrameCount().opens }
        let totalFramesPlusExtraRolls = normalFrames + extraFrames

        return totalFramesPlusExtraRolls > 0 ? (Double(totalSpares) / Double(totalFramesPlusExtraRolls) * 100).rounded(toPlaces: 2) : 0.0
    }

    func getSeriesOpenPercentage() -> Double {
        let normalFrames = games.count * 9
        let totalOpenFrames = games.reduce(0) { $0 + $1.openFrameCount }

        let extraFrames = games.reduce(0) { $0 + $1.lastFrameCount().strikes + $1.lastFrameCount().spares + $1.lastFrameCount().opens }
        let totalFramesPlusExtraRolls = normalFrames + extraFrames

        return totalFramesPlusExtraRolls > 0 ? (Double(totalOpenFrames) / Double(totalFramesPlusExtraRolls) * 100).rounded(toPlaces: 2) : 0.0
    }


    func isCurrentGameActive() -> Bool {
        guard let currentGame else { return false }
        return currentGame.frames.contains { $0.frameType == .unfinished }
    }

    func getCurrentGameScore() -> Int? {
        guard let currentGame else { return nil }
        return currentGame.currentScore
    }
    
    mutating func save(game: Game) {
        games.append(game)
    }
    
    mutating func newGame() {
        currentGame = Game()
    }
}

extension Series {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
