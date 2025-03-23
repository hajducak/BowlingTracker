import XCTest
import Combine
@testable import BowlingTracker

class BasicStatisticsViewModelTests: XCTestCase {
    var sut: BasicStatisticsViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = BasicStatisticsViewModel(series: [])
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.totalGames, 0)
        XCTAssertEqual(sut.totalScore, 0)
        XCTAssertEqual(sut.totalAverage, 0.0)
        XCTAssertEqual(sut.totalStrikesPercentage, 0.0)
        XCTAssertEqual(sut.totalSparesPercentage, 0.0)
        XCTAssertEqual(sut.totalOpensPercentage, 0.0)
        XCTAssertEqual(sut.totalSplitsPercentage, 0.0)
        XCTAssertEqual(sut.totalStrikesCount, "0/0")
        XCTAssertEqual(sut.totalSparesCount, "0/0")
        XCTAssertEqual(sut.totalOpensCount, "0/0")
        XCTAssertEqual(sut.totalSplitsCount, "0/0")
    }
    
    // MARK: - Statistics Calculation Tests
    
    func testCalculateStatistics_WithPerfectGame() {
        // Given
        var frames = (1...9).map { index in
            Frame(rolls: [Roll(knockedDownPins: (1...10).map { Pin(id: $0) })], index: index)
        }
        frames.append(Frame(rolls: [
            Roll(knockedDownPins: (1...10).map { Pin(id: $0) }),
            Roll(knockedDownPins: (1...10).map { Pin(id: $0) }),
            Roll(knockedDownPins: (1...10).map { Pin(id: $0) })
        ], index: 10))
        let game = Game(frames: frames)
        let series = Series(name: "Perfect Series", tag: .league, games: [game])
        
        // When
        sut.series = [series]
        
        // Then
        XCTAssertEqual(sut.totalGames, 1)
        XCTAssertEqual(sut.totalScore, 300)
        XCTAssertEqual(sut.totalAverage, 300.0)
        XCTAssertEqual(sut.totalStrikesPercentage, 100.0)
        XCTAssertEqual(sut.totalSparesPercentage, 0.0)
        XCTAssertEqual(sut.totalOpensPercentage, 0.0)
        XCTAssertEqual(sut.totalSplitsPercentage, 0.0)
        XCTAssertEqual(sut.totalStrikesCount, "12/12")
        XCTAssertEqual(sut.totalSparesCount, "0/10")
        XCTAssertEqual(sut.totalOpensCount, "0/10")
        XCTAssertEqual(sut.totalSplitsCount, "0/10")
    }
    
    func testCalculateStatistics_WithMixedGame() {
        // Given
        var frames: [Frame] = []
        // Strike
        frames.append(Frame(rolls: [Roll(knockedDownPins: (1...10).map { Pin(id: $0) })], index: 1))
        // Spare
        frames.append(Frame(rolls: [
            Roll(knockedDownPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)]),
            Roll(knockedDownPins: [Pin(id: 6), Pin(id: 7), Pin(id: 8), Pin(id: 9), Pin(id: 10)])
        ], index: 2))
        // Open
        frames.append(Frame(rolls: [
            Roll(knockedDownPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3)]),
            Roll(knockedDownPins: [Pin(id: 4), Pin(id: 5)])
        ], index: 3))
        // Split
        frames.append(Frame(rolls: [
            Roll(knockedDownPins: [Pin(id: 7), Pin(id: 10)]),
            Roll(knockedDownPins: [])
        ], index: 4))
        let game = Game(frames: frames)
        let series = Series(name: "Mixed Series", tag: .league, games: [game])
        
        // When
        sut.series = [series]
        
        // Then
        XCTAssertEqual(sut.totalGames, 1)
        XCTAssertEqual(sut.totalStrikesPercentage, 8.333333333333332)
        XCTAssertEqual(sut.totalSparesPercentage, 10)
        XCTAssertEqual(sut.totalOpensPercentage, 20)
        XCTAssertEqual(sut.totalSplitsPercentage, 10)
        XCTAssertEqual(sut.totalStrikesCount, "1/12")
        XCTAssertEqual(sut.totalSparesCount, "1/10")
        XCTAssertEqual(sut.totalOpensCount, "2/10")
        XCTAssertEqual(sut.totalSplitsCount, "1/10")
    }
    
    func testCalculateStatistics_WithMultipleGames() {
        // Given
        
        let frames1 = (1...10).map { index in
            Frame(rolls: [Roll(knockedDownPins: (1...10).map { Pin(id: $0) })], index: index)
        }
        let game1 = Game(frames: frames1)
        
        let frames2 = (1...10).map { index in
            Frame(rolls: [
                Roll(knockedDownPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)]),
                Roll(knockedDownPins: [Pin(id: 6), Pin(id: 7), Pin(id: 8), Pin(id: 9), Pin(id: 10)])
            ], index: index)
        }
        let game2 = Game(frames: frames2)
        
        let series = Series(name: "Multiple Games Series", tag: .league, games: [game1, game2])
        
        // When
        sut.series = [series]
        
        // Then
        XCTAssertEqual(sut.totalGames, 2)
        XCTAssertEqual(sut.totalStrikesPercentage, 50.0)
        XCTAssertEqual(sut.totalSparesPercentage, 50.0)
        XCTAssertEqual(sut.totalOpensPercentage, 0.0)
        XCTAssertEqual(sut.totalSplitsPercentage, 0.0)
        XCTAssertEqual(sut.totalStrikesCount, "10/20")
        XCTAssertEqual(sut.totalSparesCount, "10/20")
        XCTAssertEqual(sut.totalOpensCount, "0/20")
        XCTAssertEqual(sut.totalSplitsCount, "0/20")
    }
    
    func testCalculateStatistics_WithEmptySeries() {
        // Given
        let series = Series(name: "Empty Series", tag: .league)
        
        // When
        sut.series = [series]
        
        // Then
        XCTAssertEqual(sut.totalGames, 0)
        XCTAssertEqual(sut.totalScore, 0)
        XCTAssertEqual(sut.totalAverage, 0.0)
        XCTAssertEqual(sut.totalStrikesPercentage, 0.0)
        XCTAssertEqual(sut.totalSparesPercentage, 0.0)
        XCTAssertEqual(sut.totalOpensPercentage, 0.0)
        XCTAssertEqual(sut.totalSplitsPercentage, 0.0)
        XCTAssertEqual(sut.totalStrikesCount, "0/0")
        XCTAssertEqual(sut.totalSparesCount, "0/0")
        XCTAssertEqual(sut.totalOpensCount, "0/0")
        XCTAssertEqual(sut.totalSplitsCount, "0/0")
    }
} 
