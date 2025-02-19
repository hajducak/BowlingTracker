import XCTest
@testable import SportTracker

final class GameTests: XCTestCase {
    func test_whenPerfectGame_thenScoreIs300() {
        let strikeRoll = Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))
        let perfectFrames = Array(repeating: Frame(rolls: [strikeRoll]), count: 9)
        let finalFrame = Frame(rolls: [strikeRoll, strikeRoll, strikeRoll])
        let game = Game(frames: perfectFrames + [finalFrame])
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 300, "Perfektná hra by mala mať skóre 300")
    }
    
    func test_whenCleanGame_thenScoreIsCorrect() {
        let spareRoll = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 200, "Čistá hra by mala mať skóre 200")
    }
    
    func test_whenGameWithOpenFrames_thenScoreIsCorrect() {
        let openFrame = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [])]
        let spareRoll = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: openFrame), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: openFrame), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: openFrame)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 176, "Hra so zmiešanými open frames by mala mať skóre 176")
    }
    
    func test_whenMixedGame_thenScoreIsCorrect() {
        let roll72 = [Roll(knockedDownPins: Set([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 7)])), Roll(knockedDownPins: Set([Pin(id: 8), Pin(id: 9)]))]
        let openRoll5 = [Roll(knockedDownPins: Set([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)])), Roll(knockedDownPins: [])]
        let spareRoll = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: roll72), Frame(rolls: strikeRoll),
            Frame(rolls: openRoll5), Frame(rolls: strikeRoll),
            Frame(rolls: strikeRoll), Frame(rolls: strikeRoll),
            Frame(rolls: openRoll5), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: openRoll5)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 159, "Mixovaná hra by mala mať skóre 159")
    }
    
    func test_whenCleanGame_thenMaxPossibleScoreIsCorrect() {
        let spareRoll = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.maxPossibleScore, 250, "Max možné skóre by malo byť 250")
    }
    
    func test_whenOpenFrames_thenMaxPossibleScoreIsCorrect() {
        let openFrame = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [])]
        let spareRoll = [Roll(knockedDownPins: Set((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: openFrame), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll), Frame(rolls: strikeRoll),
            Frame(rolls: spareRoll)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.maxPossibleScore, 239, "Max možné skóre by malo byť 239")
    }
    
    func test_whenMixedGame_thenMaxPossibleScoreIsCorrect() {
        let roll72 = [Roll(knockedDownPins: Set([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 7)])), Roll(knockedDownPins: Set([Pin(id: 8), Pin(id: 9)]))]
        let openRoll5 = [Roll(knockedDownPins: Set([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)])), Roll(knockedDownPins: [])]
        let strikeRoll = [Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: roll72), Frame(rolls: strikeRoll),
            Frame(rolls: openRoll5), Frame(rolls: strikeRoll),
            Frame(rolls: strikeRoll)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.maxPossibleScore, 239, "Max možné skóre by malo byť 239")
    }
    
    private func printGameLog(game: Game, maxScore: Bool = false) {
        let frameStrings = game.frames.map { frame -> String in
            if frame.frameType == .strike {
                return "X"
            } else if frame.frameType == .spare {
                return "9/"
            } else {
                let firstRoll = frame.rolls.first?.knockedDownPins.count ?? 0
                let secondRoll = frame.rolls.count > 1 ? frame.rolls[1].knockedDownPins.count : 0
                return "\(firstRoll)-\(secondRoll)"
            }
        }
        print(frameStrings.joined(separator: " ") + " = \(maxScore ? game.maxPossibleScore : game.currentScore)")
    }
}
