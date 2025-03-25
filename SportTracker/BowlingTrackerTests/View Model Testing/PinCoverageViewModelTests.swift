import XCTest
import Combine
@testable import BowlingTracker

final class PinCoverageViewModelTests: XCTestCase {
    var sut: PinCoverageViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = PinCoverageViewModel(series: [])
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_givenNoGames_whenCalculateCoverage_thenReturnsZeroPercentageIsSet() {
        sut = PinCoverageViewModel(series: [])
        
        sut.selectedPinIds = [10]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 0.0)
        XCTAssertEqual(sut.coverageCount, "0/0")
    }
    
    func test_givenTenPinIsLeftAndCovered_whenCalculateCoverage_thenCorrectPercentageIsSet() {
        let series = createTestSeriesWithTenPinCoverage(covered: true)
        sut = PinCoverageViewModel(series: series)

        sut.selectedPinIds = [10]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 100.0)
        XCTAssertEqual(sut.coverageCount, "1/1")
    }
    
    func test_givenTenPinIsLeftAndNotCovered_whenCalculateCoverage_thenCorrectPercentageIsSet() {
        let series = createTestSeriesWithTenPinCoverage(covered: false)
        sut = PinCoverageViewModel(series: series)
        
        sut.selectedPinIds = [10]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 0.0)
        XCTAssertEqual(sut.coverageCount, "0/1")
    }
    
    func test_givenTestingMultipleFrames_whenCalculateCoverage_thenCorrectPercentageIsSet() {
        let series = createTestSeriesWithMultipleFrames()
        sut = PinCoverageViewModel(series: series)
        
        sut.selectedPinIds = [10]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 50.0)
        XCTAssertEqual(sut.coverageCount, "1/2")
    }
    
    func test_givenTenPinIsLeftAndPartiallyCovered_whenCalculateCoverage_thenNotCountedAsCovered() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll(knockedDownPins: (1...9).map { Pin(id: $0) }),
                Roll(knockedDownPins: [Pin(id: 10), Pin(id: 7)]) // Knocked down 10-pin plus extra pin
            ], index: 1)
        ])
        
        let series = [Series(name: "Test Series", tag: .league, games: [game])]
        sut = PinCoverageViewModel(series: series)
        
        sut.selectedPinIds = [10]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 0.0)
        XCTAssertEqual(sut.coverageCount, "0/1")
    }
    
    func test_givenSplitIsLeftAndPartiallyCovered_whenCalculateCoverage_thenNotCountedAsCovered() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll(knockedDownPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 5), Pin(id: 6), Pin(id: 8), Pin(id: 9), Pin(id: 10)]),
                Roll(knockedDownPins: [Pin(id: 4)]) // Only knocked down one of the split pins
            ], index: 1)
        ])
        
        let series = [Series(name: "Test Series", tag: .league, games: [game])]
        sut = PinCoverageViewModel(series: series)
        
        sut.selectedPinIds = [4, 7]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 0.0)
        XCTAssertEqual(sut.coverageCount, "0/1")
    }
    
    func test_givenSplitIsLeftAndFullyCovered_whenCalculateCoverage_thenCountedAsCovered() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll(knockedDownPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 5), Pin(id: 6), Pin(id: 8), Pin(id: 9), Pin(id: 10)]),
                Roll(knockedDownPins: [Pin(id: 4), Pin(id: 7)]) // Knocked down exactly the split pins
            ], index: 1)
        ])
        
        let series = [Series(name: "Test Series", tag: .league, games: [game])]
        sut = PinCoverageViewModel(series: series)
        
        sut.selectedPinIds = [4, 7]
        sut.calculateCoverage()
        
        XCTAssertEqual(sut.coveragePercentage, 100.0)
        XCTAssertEqual(sut.coverageCount, "1/1")
    }
    
    private func createTestSeriesWithTenPinCoverage(covered: Bool) -> [Series] {
        let game = Game(frames: [
            Frame(rolls: [
                Roll(knockedDownPins: (1...9).map { Pin(id: $0) }),
                covered ? Roll(knockedDownPins: [Pin(id: 10)]) : Roll(knockedDownPins: [])
            ], index: 1)
        ])
        
        return [Series(name: "Test Series", tag: .league, games: [game])]
    }
    
    private func createTestSeriesWithMultipleFrames() -> [Series] {
        let game = Game(frames: [
            Frame(rolls: [
                Roll(knockedDownPins: (1...9).map { Pin(id: $0) }),
                Roll(knockedDownPins: [Pin(id: 10)])
            ], index: 1),
            
            Frame(rolls: [
                Roll(knockedDownPins: (1...9).map { Pin(id: $0) }),
                Roll(knockedDownPins: [])
            ], index: 2)
        ])
        
        return [Series(name: "Test Series", tag: .league, games: [game])]
    }
} 
