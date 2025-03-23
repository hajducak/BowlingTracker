import Foundation

enum SeriesType: String, Codable {
    case tournament, practise, league, other
}

typealias SeriesStatistics = (percentage: Double, count: String)

struct Series: Codable, Identifiable {
    let id: String
    let date: Date
    let name: String
    let description: String
    let tag: SeriesType
    var games: [Game]
    var currentGame: Game?
    var oilPatternName: String?
    var oilPatternURL: String?
    var house: String?

    init(
        date: Date = Date.now,
        name: String,
        description: String = "",
        oilPatternName: String? = nil,
        oilPatternURL: String? = nil,
        house: String? = nil,
        tag: SeriesType,
        games: [Game] = [],
        currentGame: Game? = Game()
    ) {
        self.id = UUID().uuidString
        self.date = date
        self.name = name
        self.description = description
        self.tag = tag
        self.games = games
        self.currentGame = currentGame
        self.oilPatternName = oilPatternName
        self.oilPatternURL = oilPatternURL
        self.house = house
    }
    
    func getSeriesScore() -> Int {
        return games.reduce(0) { $0 + $1.currentScore }
    }

    func getSeriesAverage() -> Double {
        guard getSeriesScore() != 0, games.count != 0 else { return 0 }
        return Double(getSeriesScore()) / Double(games.count)
    }
    
    var seriesStrikeStatistics: SeriesStatistics {
        let strikesPerGame = 12
        let strikesPossibility = strikesPerGame  * games.count
        let totalStrikes = games.reduce(0) { $0 + $1.strikeCount }

        let percentage = strikesPossibility > 0 ?  (Double(totalStrikes) / Double(strikesPossibility) * 100).rounded(toPlaces: 2) : 0.0
        let count = "\(totalStrikes)/\(strikesPossibility)"

        return (percentage, count)
    }

    var seriesSpareStatistics: SeriesStatistics {
        let sparesPerGame = 10
        let sparesPossibility = sparesPerGame * games.count
        let totalSpares = games.reduce(0) { $0 + $1.spareCount }


        let percentage = sparesPossibility > 0 ? (Double(totalSpares) / Double(sparesPossibility) * 100).rounded(toPlaces: 2) : 0.0
        let count = "\(totalSpares)/\(sparesPossibility)"
        return (percentage, count)
    }

    var seriesOpenStatistics: SeriesStatistics {
        let opensPerGame = 10
        let opensPossibility = games.count * opensPerGame
        let totalOpenFrames = games.reduce(0) { $0 + $1.openFrameCount }

        let percentage = opensPossibility > 0 ? (Double(totalOpenFrames) / Double(opensPossibility) * 100).rounded(toPlaces: 2) : 0.0
        let count = "\(totalOpenFrames)/\(opensPossibility)"
        
        return (percentage, count)
    }
    
    var seriesSplitStatistics: SeriesStatistics {
        let totalFrames = games.count * 10
        let totalSplits = games.reduce(0) { $0 + $1.splitCount }

        let percentage = totalFrames > 0 ? (Double(totalSplits) / Double(totalFrames) * 100).rounded(toPlaces: 2) : 0.0
        let count = "\(totalSplits)/\(totalFrames)"
        
        return (percentage, count)
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
        formatter.dateFormat = "HH:mm dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
