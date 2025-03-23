import XCTest
@testable import BowlingTracker

final class SeriesTests: XCTestCase {
    
    func test_whenInit_thenParametersAreSet() {
        let series = Series(name: "Test Series", tag: .tournament)
        
        XCTAssertEqual(series.name, "Test Series")
        XCTAssertEqual(series.tag, .tournament)
        XCTAssertEqual(series.games.count, 0)
        XCTAssertEqual(series.currentGame?.frames.count, 10)
    }

    func test_givenRoll_whenCurrentScore_thenScoreCalculationIsCorrect() {
        var series = Series(name: "Practise", tag: .practise)
    
        series.currentGame?.addRoll(knockedDownPins: Roll.tenPins)
        series.currentGame?.addRoll(knockedDownPins: Roll.sevenPins)
        series.currentGame?.addRoll(knockedDownPins: Roll.threePins)
        
        XCTAssertEqual(series.getCurrentGameScore(), 30)
    }
    
    func test_givenCompletedGame_whenSaveGameAndNewgame_thenGameIsSavedAndNewIsCreated() {
        var series = Series(name: "League Match", tag: .league)
        
        for _ in 0..<12 {
            series.currentGame?.addRoll(knockedDownPins:  Roll.tenPins)
        }
        
        XCTAssertFalse(series.isCurrentGameActive())
        
        series.save(game: series.currentGame!)
        XCTAssertEqual(series.games.count, 1)
        
        series.newGame()
        XCTAssertEqual(series.currentGame?.frames.count, 10)
        XCTAssertTrue(series.isCurrentGameActive())
    }
    
    func test_givenTwoGames_whenSeriesScoreCalculation_thenScoreIsCorrect() {
        var series = Series(name: "Test Series", tag: .other)
        
        var game1 = Game()
        for _ in 0..<12 { game1.addRoll(knockedDownPins: Roll.tenPins) }
        series.games.append(game1)
        
        var game2 = Game()
        for _ in 0..<10 { game2.addRoll(knockedDownPins: Roll.ninePins); game2.addRoll(knockedDownPins: Roll.onePins) }
        series.games.append(game2)

        XCTAssertEqual(series.getSeriesScore(), 481)
    }

    func test_givenTwoGames_whenSeriesScoreCalculation_thenAverageIsCorrect() {
        var series = Series(name: "Test Series", tag: .other)
        
        var game1 = Game()
        for _ in 0..<12 { game1.addRoll(knockedDownPins: Roll.tenPins) }
        series.games.append(game1)
        
        var game2 = Game()
        for _ in 0..<10 { game2.addRoll(knockedDownPins: Roll.ninePins); game2.addRoll(knockedDownPins: Roll.onePins) }
        series.games.append(game2)

        XCTAssertEqual(series.getSeriesAverage(), 240.5)
    }

    func testSeries_AllStrikes() {
        let series: Series = .mock300Series(name: "Series 300")
        
        XCTAssertEqual(series.seriesStrikeStatistics.percentage, 100.00)
        XCTAssertEqual(series.seriesSpareStatistics.percentage, 0.00)
        XCTAssertEqual(series.seriesOpenStatistics.percentage, 0.00)
    }
    
    func testSeries_MixedStrikesSparesOpens() {
        let game = Game(frames: [
            Frame(rolls: [Roll.roll10], index: 1), // Strike
            Frame(rolls: [Roll.roll5, Roll.roll5], index: 2), // Spare
            Frame(rolls: [Roll.roll3, Roll.roll6], index: 3), // Open
            Frame(rolls: [Roll.roll10], index: 4), // Strike
            Frame(rolls: [Roll.roll7, Roll.roll3], index: 5), // Spare
            Frame(rolls: [Roll.roll2, Roll.roll4], index: 6), // Open
            Frame(rolls: [Roll.roll10], index: 7), // Strike
            Frame(rolls: [Roll.roll10], index: 8), // Strike
            Frame(rolls: [Roll.roll8, Roll.roll2], index: 9), // Spare
            Frame(rolls: [Roll.roll10, Roll.roll10, Roll.roll10], index: 10) // 3 Strikes
        ])
        
        let series = Series(name: "dummyName", tag: .tournament, games: [game])
        
        XCTAssertEqual(series.seriesStrikeStatistics.percentage, 58.33) // 7 strikes in total
        XCTAssertEqual(series.seriesSpareStatistics.percentage, 30) // 3 spares
        XCTAssertEqual(series.seriesOpenStatistics.percentage, 20) // 2 opens
    }
    
    func testSeries_AllSparesAndOneX() {
        let series: Series = .mockAllSparesAndOneXSeries(name: "dummyName")
        
        XCTAssertEqual(series.seriesStrikeStatistics.percentage, 2.78) // Only 1 strike in last frame
        XCTAssertEqual(series.seriesSpareStatistics.percentage, 100) // 30 spares in total
        XCTAssertEqual(series.seriesOpenStatistics.percentage, 0.00)
    }
    
    func testSeries_AllOpens() {
        let series: Series = .mockAllOpensSeries(name: "dummySeries")
        
        XCTAssertEqual(series.seriesStrikeStatistics.percentage, 0.00)
        XCTAssertEqual(series.seriesSpareStatistics.percentage, 0.00)
        XCTAssertEqual(series.seriesOpenStatistics.percentage, 100.00)
    }
    
    func testSeries_MultipleGames() {
        let game1 = Game(frames: [
            Frame(rolls: [Roll.roll10], index: 1), // Strike
            Frame(rolls: [Roll.roll10], index: 2), // Strike
            Frame(rolls: [Roll.roll5, Roll.roll5], index: 3), // Spare
            Frame(rolls: [Roll.roll3, Roll.roll4], index: 4), // Open
            Frame(rolls: [Roll.roll10], index: 5), // Strike
            Frame(rolls: [Roll.roll10], index: 6), // Strike
            Frame(rolls: [Roll.roll2, Roll.roll6], index: 7), // Open
            Frame(rolls: [Roll.roll8, Roll.roll2], index: 8), // Spare
            Frame(rolls: [Roll.roll10], index: 9), // Strike
            Frame(rolls: [Roll.roll10, Roll.roll10, Roll.roll10], index: 10) // 3 Strikes
        ])
        
        let game2 = Game(frames: [
            Frame(rolls: [Roll.roll10], index: 1), // Strike
            Frame(rolls: [Roll.roll10], index: 2), // Strike
            Frame(rolls: [Roll.roll5, Roll.roll5], index: 3), // Spare
            Frame(rolls: [Roll.roll3, Roll.roll4], index: 4), // Open
            Frame(rolls: [Roll.roll10], index: 5), // Strike
            Frame(rolls: [Roll.roll10], index: 6), // Strike
            Frame(rolls: [Roll.roll2, Roll.roll6], index: 7), // Open
            Frame(rolls: [Roll.roll8, Roll.roll2], index: 8), // Spare
            Frame(rolls: [Roll.roll10], index: 9), // Strike
            Frame(rolls: [Roll.roll10, Roll.roll10, Roll.roll10], index: 10) // 3 Strikes
        ])
        
        let series = Series(name: "dummySeries", tag: .tournament, games: [game1, game2])
        
        XCTAssertEqual(series.seriesStrikeStatistics.percentage, 66.67) // 16 strikes
        XCTAssertEqual(series.seriesSpareStatistics.percentage, 20) // 6 spares
        XCTAssertEqual(series.seriesOpenStatistics.percentage, 20) // 4 opens
    }
    
    func test_whenSaveGame_thenGameIsSet() {
        let game = Game(frames: [
            Frame(rolls: [Roll.roll10], index: 1),
            Frame(rolls: [Roll.roll5, Roll.roll5], index: 2),
            Frame(rolls: [Roll.roll3, Roll.roll6], index: 3),
            Frame(rolls: [Roll.roll10], index: 4),
            Frame(rolls: [Roll.roll7, Roll.roll3], index: 5),
            Frame(rolls: [Roll.roll2, Roll.roll4], index: 6),
            Frame(rolls: [Roll.roll10], index: 7),
            Frame(rolls: [Roll.roll10], index: 8),
            Frame(rolls: [Roll.roll8, Roll.roll2], index: 9),
            Frame(rolls: [Roll.roll10, Roll.roll10, Roll.roll10], index: 10)
        ])
        
        var series = Series(name: "dummyName", tag: .tournament, games: [])
        series.save(game: game)
        XCTAssertEqual(series.games.last?.id, game.id)
    }

    func test_whenAddNewGame_thenGameIsSet() {
        var series = Series(name: "dummyName", tag: .tournament, games: [])
        series.currentGame = nil
        series.newGame()
        XCTAssertNotNil(series.currentGame)
    }
}

extension Series {
    static func mock300Series(name: String) -> Series {
        Series(name: name, tag: .league, games: [
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
        ], currentGame: nil)
    }
    
    static func mockAllSparesAndOneXSeries(name: String) -> Series {
        Series(name: name, tag: .league, games: [
            Game(frames: [
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 1),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 2),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 3),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 4),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 5),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 6),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 7),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 8),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 9),
                Frame(rolls: [Roll.roll9, Roll.roll1, Roll.roll9], index: 10)
            ]),
            Game(frames: [
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 1),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 2),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 3),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 4),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 5),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 6),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 7),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 8),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 9),
                Frame(rolls: [Roll.roll9, Roll.roll1, Roll.roll9], index: 10)
            ]),
            Game(frames: [
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 1),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 2),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 3),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 4),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 5),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 6),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 7),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 8),
                Frame(rolls: [Roll.roll9, Roll.roll1], index: 9),
                Frame(rolls: [Roll.roll9, Roll.roll1, Roll.roll10], index: 10)
            ])
        ], currentGame: nil)
    }
    
    static func mockAllOpensSeries(name: String) -> Series {
        Series(name: name, tag: .league, games: [
            Game(frames: [
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 1),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 2),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 3),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 4),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 5),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 6),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 7),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 8),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 9),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 10)
            ]),
            Game(frames: [
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 1),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 2),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 3),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 4),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 5),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 6),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 7),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 8),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 9),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 10)
            ]),
            Game(frames: [
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 1),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 2),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 3),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 4),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 5),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 6),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 7),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 8),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 9),
                Frame(rolls: [Roll.roll8, Roll.roll1], index: 10)
            ])
        ], currentGame: nil)
    }
}
