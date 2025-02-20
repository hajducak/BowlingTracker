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
    var currentGame: Game

    init(id: String? = nil, date: Date = Date.now, name: String, tag: SeriesType, games: [Game] = [], currentGame: Game = Game()) {
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

extension Series {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
}

extension Series {
    static func mockSeries(name: String) -> Series {
        Series(id: UUID().uuidString, name: name, tag: .league, games: [
            Game(frames: [
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 1),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 2),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 3),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 4),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 5),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 6),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 7),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 8),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 9),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins)], index: 10)
            ]),
            Game(frames: [
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 1),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 2),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 3),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 4),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 5),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 6),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 7),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 8),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 9),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins)], index: 10)
            ]),
            Game(frames: [
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 1),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 2),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 3),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 4),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 5),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 6),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 7),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 8),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 9),
                Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins)], index: 10)
            ])
        ])
    }
}
