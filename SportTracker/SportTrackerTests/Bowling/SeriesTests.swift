import XCTest
@testable import SportTracker

final class SeriesTests: XCTestCase {
    
    func test_whenInit_thenParametersAreSet() {
        let series = Series(name: "Test Series", tag: .tournament)
        
        XCTAssertEqual(series.name, "Test Series")
        XCTAssertEqual(series.tag, .tournament)
        XCTAssertEqual(series.games.count, 0)
        XCTAssertEqual(series.currentGame.frames.count, 10)
    }

    func test_givenRoll_whenCurrentScore_thenScoreCalculationIsCorrect() {
        var series = Series(name: "Training", tag: .training)
    
        series.currentGame.addRoll(knockedDownPins: Roll.tenPins)
        series.currentGame.addRoll(knockedDownPins: Roll.sevenPins)
        series.currentGame.addRoll(knockedDownPins: Roll.threePins)
        
        XCTAssertEqual(series.getCurrentGameScore(), 30)
    }
    
    func test_givenCompletedGame_whenSaveGameAndNewgame_thenGameIsSavedAndNewIsCreated() {
        var series = Series(name: "League Match", tag: .league)
        
        for _ in 0..<12 {
            series.currentGame.addRoll(knockedDownPins:  Roll.tenPins)
        }
        
        XCTAssertFalse(series.isCurrentGameActive())
        
        series.saveCurrentGame()
        XCTAssertEqual(series.games.count, 1)
        
        series.newGame()
        XCTAssertEqual(series.currentGame.frames.count, 10)
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
}
