import XCTest
import Combine
@testable import BowlingTracker

class GameViewModelTests: XCTestCase {
    var sut: GameViewModel!
    var game: Game!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        game = Game()
        sut = GameViewModel(game: game)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        game = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.selectedPins, [])
        XCTAssertEqual(sut.disabledPins, [])
        XCTAssertFalse(sut.selectingFallenPins)
        XCTAssertEqual(sut.currentFrameIndex, 0)
        XCTAssertEqual(sut.gameLane, "")
        XCTAssertFalse(sut.saveGameIsEnabled)
        XCTAssertFalse(sut.spareIsEnabled)
        XCTAssertTrue(sut.strikeIsEnabled)
        XCTAssertTrue(sut.addRollIsEnabled)
    }
    
    // MARK: - Pin Selection Tests
    
    func testAddRoll_WithStrike() {
        // Given
        sut.strikeIsEnabled = true
        
        // When
        sut.addStrike()
        
        // Then
        XCTAssertEqual(sut.game.frames[0].rolls.count, 1)
        XCTAssertEqual(sut.game.frames[0].rolls[0].knockedDownPins.count, 10)
        XCTAssertEqual(sut.disabledPins, Set(1...10))
    }
    
    func testAddRoll_WithSpare() {
        // Given
        sut.spareIsEnabled = true
        sut.selectedPins = [1, 2, 3, 4, 5]
        
        // When
        sut.addRoll()
        
        // Then
        XCTAssertEqual(sut.game.frames[0].rolls.count, 1)
        XCTAssertEqual(sut.game.frames[0].rolls[0].knockedDownPins.count, 5)
        XCTAssertEqual(sut.disabledPins, Set(1...5))
    }
    
    func testAddRoll_WithPartialPins() {
        // Given
        sut.selectedPins = [1, 2, 3]
        
        // When
        sut.addRoll()
        
        // Then
        XCTAssertEqual(sut.game.frames[0].rolls.count, 1)
        XCTAssertEqual(sut.game.frames[0].rolls[0].knockedDownPins.count, 3)
        XCTAssertEqual(sut.disabledPins, Set(1...3))
    }
    
    // MARK: - Undo Tests
    
    func testUndoRoll() {
        // Given
        sut.selectedPins = [1, 2, 3, 4, 5]
        sut.addRoll()
        
        // When
        sut.undoRoll()
        
        // Then
        XCTAssertEqual(sut.game.frames[0].rolls.count, 0)
        XCTAssertEqual(sut.selectedPins, [])
        XCTAssertEqual(sut.disabledPins, [])
    }
    
    // MARK: - Save Game Tests
    
    func testSaveGame() {
        // Given
        let expectation = XCTestExpectation(description: "Game should be saved")
        sut.gameLane = "Lane 1"
        sut.game.frames = [Frame(rolls: [Roll(knockedDownPins: [Pin(id: 1)])], index: 1)]
        
        // When
        sut.gameSaved
            .sink { savedGame in
                XCTAssertEqual(savedGame.lane, "Lane 1")
                XCTAssertEqual(savedGame.frames.count, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.saveGame()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Button State Tests
    
    func testSaveGameButtonState() {
        // Given
        sut.gameLane = "Lane 1"
        sut.game.frames = [Frame(rolls: [Roll(knockedDownPins: [Pin(id: 1)])], index: 1)]
        
        // When
        let expectation = XCTestExpectation(description: "Save button should be enabled")
        
        sut.$saveGameIsEnabled
            .dropFirst()
            .sink { isEnabled in
                XCTAssertTrue(isEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStrikeButtonState() {
        // Given
        sut.addStrike()
        
        // When
        let expectation = XCTestExpectation(description: "Strike button should be disabled")
        
        sut.$strikeIsEnabled
            .dropFirst()
            .sink { isEnabled in
                XCTAssertFalse(isEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSpareButtonState() {
        // Given
        sut.selectedPins = [1, 2, 3, 4, 5]
        sut.addRoll()
        
        // When
        let expectation = XCTestExpectation(description: "Spare button should be enabled")
        
        sut.$spareIsEnabled
            .dropFirst()
            .sink { isEnabled in
                XCTAssertTrue(isEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 10th Frame Tests
    
    func testTenthFrame_WithStrike() {
        // Given
        sut.game.frames = (1...9).map { Frame(rolls: [Roll(knockedDownPins: [Pin(id: 1)])], index: $0) }
        sut.game.frames.append(Frame(rolls: [], index: 10))
        
        // When
        sut.addStrike()
        
        // Then
        XCTAssertEqual(sut.game.frames[9].rolls.count, 1)
        XCTAssertEqual(sut.game.frames[9].rolls[0].knockedDownPins.count, 10)
        XCTAssertEqual(sut.disabledPins, [])
    }
    
    func testTenthFrame_WithSpare() {
        // Given
        sut.game.frames = (1...9).map { Frame(rolls: [Roll(knockedDownPins: [Pin(id: 1)])], index: $0) }
        sut.game.frames.append(Frame(rolls: [], index: 10))
        sut.selectedPins = [1, 2, 3, 4, 5]
        
        // When
        sut.addRoll()
        
        // Then
        XCTAssertEqual(sut.game.frames[9].rolls.count, 1)
        XCTAssertEqual(sut.game.frames[9].rolls[0].knockedDownPins.count, 5)
        XCTAssertEqual(sut.disabledPins, [])
    }
} 
