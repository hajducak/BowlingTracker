import XCTest
@testable import BowlingTracker

final class GameTests: XCTestCase {
    func test_whenAddRoll_thenRollIsSet() {
        let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))
        var game = Game(frames: [Frame.init(rolls: [strikeRoll], index: 0)])

        printGameLog(game: game)
        game.addRoll(knockedDownPins: [Pin.init(id: 1)])
        
        XCTAssertNotNil(game.frames.last?.rolls)
        XCTAssertEqual(game.frames.last?.rolls.isEmpty, false)
        XCTAssertEqual(game.frames.last?.rolls.first?.knockedDownPins.first?.id , 1)
    }

    func test_whenUndoRoll_thenRollIsDeleted() {
        let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))
        var game = Game(frames: [Frame.init(rolls: [strikeRoll], index: 0)])
        
        game.undoRoll()

        XCTAssertEqual(game.frames.last?.rolls.isEmpty, true)
    }
    
    func test_whenPerfectGame_thenScoreIs300() {
         let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))
         var perfectFrames: [Frame] = []
         for i in 1...9 {
             perfectFrames.append(Frame(rolls: [strikeRoll], index: i))
         }
         let finalFrame = Frame(rolls: [strikeRoll, strikeRoll, strikeRoll], index: 10)
         let game = Game(frames: perfectFrames + [finalFrame])
         
         printGameLog(game: game)
         XCTAssertEqual(game.currentScore, 300, "In perfect game should score 300")
     }
     
    
    func test_whenCleanGame_thenScoreIsCorrect() {
        let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))
        let nineRoll = Roll(knockedDownPins: Array((1...9).map { Pin(id: $0) }))
        let oneRoll = Roll(knockedDownPins: [Pin(id: 10)])

        let spareRolls = [nineRoll, oneRoll]
        let strikeRolls = [strikeRoll]
        let frames: [Frame] = [
            Frame(rolls: spareRolls, index: 1), Frame(rolls: strikeRolls, index: 2),
            Frame(rolls: spareRolls, index: 3), Frame(rolls: strikeRolls, index: 4),
            Frame(rolls: spareRolls, index: 5), Frame(rolls: strikeRolls, index: 6),
            Frame(rolls: spareRolls, index: 7), Frame(rolls: strikeRolls, index: 8),
            Frame(rolls: spareRolls, index: 9), Frame(rolls: [strikeRoll, nineRoll, oneRoll], index: 10)
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 200, "In clean game should score 200")
    }
    
    func test_whenGameWithOpenFrames_thenScoreIsCorrect() {
        let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))
        let nineRoll = Roll(knockedDownPins: Array((1...9).map { Pin(id: $0) }))
        let zeroRoll = Roll(knockedDownPins: [])
        let oneRoll = Roll(knockedDownPins: [Pin(id: 10)])
        
        let openFrames = [nineRoll, zeroRoll]
        let spareRolls = [nineRoll, oneRoll]
        let strikeRolls = [strikeRoll]
        let frames: [Frame] = [
            Frame(rolls: openFrames, index: 1), Frame(rolls: strikeRolls, index: 2),
            Frame(rolls: spareRolls, index: 3), Frame(rolls: strikeRolls, index: 4),
            Frame(rolls: spareRolls, index: 5), Frame(rolls: strikeRolls, index: 6),
            Frame(rolls: openFrames, index: 7), Frame(rolls: strikeRolls, index: 8),
            Frame(rolls: spareRolls, index: 9), Frame(rolls: [strikeRoll, nineRoll, zeroRoll], index: 10),
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 176, "This game should score 176")
    }
    
    func test_whenMixedGame_thenScoreIsCorrect() {
        let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))
        let nineRoll = Roll(knockedDownPins: Array((1...9).map { Pin(id: $0) }))
        let fiveRoll = Roll(knockedDownPins: Array([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)]))
        let zeroRoll = Roll(knockedDownPins: [])
        let oneRoll = Roll(knockedDownPins: [Pin(id: 10)])
        
        let roll72 = [Roll(knockedDownPins: Array([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 7)])), Roll(knockedDownPins: Array([Pin(id: 8), Pin(id: 9)]))]
        let openRoll50 = [fiveRoll, zeroRoll]
        let spareRolls = [nineRoll, oneRoll]
        let strikeRolls = [strikeRoll]
        let frames: [Frame] = [
            Frame(rolls: roll72, index: 1), Frame(rolls: strikeRolls, index: 2),
            Frame(rolls: openRoll50, index: 3), Frame(rolls: strikeRolls, index: 4),
            Frame(rolls: strikeRolls, index: 5), Frame(rolls: strikeRolls, index: 6),
            Frame(rolls: openRoll50, index: 7), Frame(rolls: strikeRolls, index: 8),
            Frame(rolls: spareRolls, index: 9), Frame(rolls: [strikeRoll, fiveRoll, zeroRoll], index: 10),
        ]
        let game = Game(frames: frames)
        
        printGameLog(game: game)
        XCTAssertEqual(game.currentScore, 159, "This game should have 159")
    }
    
    func test_whenCleanGame_thenMaxPossibleScoreIsCorrect() {
        var game = Game()
        let spareRoll = [Roll(knockedDownPins: Array((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: spareRoll, index: 1), Frame(rolls: strikeRoll, index: 2),
            Frame(rolls: spareRoll, index: 3), Frame(rolls: strikeRoll, index: 4),
            Frame(rolls: spareRoll, index: 5)
        ]
        frames.enumerated().forEach { index, frame in
            game.frames[index].rolls = frame.rolls
        }
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.maxPossibleScore, 250, "Max score should be 250")
    }
    
    func test_whenOpenFrames_thenMaxPossibleScoreIsCorrect() {
        var game = Game()
        let openFrame = [Roll(knockedDownPins: Array((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [])]
        let spareRoll = [Roll(knockedDownPins: Array((1...9).map { Pin(id: $0) })), Roll(knockedDownPins: [Pin(id: 10)])]
        let strikeRoll = [Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: openFrame, index: 1), Frame(rolls: strikeRoll, index: 2),
            Frame(rolls: spareRoll, index: 3), Frame(rolls: strikeRoll, index: 4),
            Frame(rolls: spareRoll, index: 5)
        ]
        frames.enumerated().forEach { index, frame in
            game.frames[index].rolls = frame.rolls
        }
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.maxPossibleScore, 239, "Max score should be 239")
    }
    
    func test_whenMixedGame_thenMaxPossibleScoreIsCorrect() {
        var game = Game()
        let roll72 = [Roll(knockedDownPins: Array([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 7)])), Roll(knockedDownPins: Array([Pin(id: 8), Pin(id: 9)]))]
        let openRoll5 = [Roll(knockedDownPins: Array([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)])), Roll(knockedDownPins: [])]
        let strikeRoll = [Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: roll72, index: 1), Frame(rolls: strikeRoll, index: 2),
            Frame(rolls: openRoll5, index: 3), Frame(rolls: strikeRoll, index: 4),
            Frame(rolls: strikeRoll, index: 5)
        ]
        frames.enumerated().forEach { index, frame in
            game.frames[index].rolls = frame.rolls
        }
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.maxPossibleScore, 239, "Max score should be 239")
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
    
    func test_givenRolls_whenSingleGame_thenTheGameScoreIsCorrect() {
        var game = Game()
        
        game.addRoll(knockedDownPins: Roll.tenPins)

        game.addRoll(knockedDownPins: Roll.ninePins)
        game.addRoll(knockedDownPins: Roll.onePins)
        
        game.addRoll(knockedDownPins: Roll.sevenPins)
        game.addRoll(knockedDownPins: Roll.twoPins)
        
        game.addRoll(knockedDownPins: Roll.sixPins)
        game.addRoll(knockedDownPins: Roll.fourPins)
        
        game.addRoll(knockedDownPins: Roll.tenPins)
        
        game.addRoll(knockedDownPins: Roll.fivePins)
        game.addRoll(knockedDownPins: Roll.threePins)
        
        game.addRoll(knockedDownPins: Roll.eightPins)
        game.addRoll(knockedDownPins: Roll.twoPins)
        
        game.addRoll(knockedDownPins: Roll.fourPins)
        game.addRoll(knockedDownPins: Roll.fivePins)
        
        game.addRoll(knockedDownPins: Roll.sevenPins)
        game.addRoll(knockedDownPins: Roll.threePins)
        
        game.addRoll(knockedDownPins: Roll.tenPins)
        game.addRoll(knockedDownPins: Roll.tenPins)
        game.addRoll(knockedDownPins: Roll.tenPins)
        
        XCTAssertEqual(game.frames.count, 10, "Frame count is not correct")
        XCTAssertEqual(game.currentScore, 165, "This game score should be 165.")
    }

    func test_given7Rolls_whenCurrentGame_thenMaxPossibleScoreIsCorrect() {
        var game = Game()
        
        game.addRoll(knockedDownPins: Roll.tenPins)
        
        game.addRoll(knockedDownPins: Roll.ninePins)
        game.addRoll(knockedDownPins: Roll.onePins)
        
        game.addRoll(knockedDownPins: Roll.sevenPins)
        game.addRoll(knockedDownPins: Roll.twoPins)
        
        game.addRoll(knockedDownPins: Roll.eightPins)
        game.addRoll(knockedDownPins: Roll.twoPins)
        
        game.addRoll(knockedDownPins: Roll.tenPins)
        
        game.addRoll(knockedDownPins: Roll.tenPins)
        
        game.addRoll(knockedDownPins: Roll.tenPins)
        

        XCTAssertEqual(game.frames.map({ $0.frameType != .unfinished }).filter({ $0 }).count, 7, "Number of finished frames is 7")
        
        XCTAssertEqual(game.currentScore, 126, "Score of this game is not correct")
        XCTAssertEqual(game.maxPossibleScore, 246, "Max score is not correct")
    }
    
    func test_whenCumulativeScoreForFrame_thenScoreIsSetCorrectly() {
        var game = Game()
        let roll72 = [Roll(knockedDownPins: Array([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 7)])), Roll(knockedDownPins: Array([Pin(id: 8), Pin(id: 9)]))]
        let openRoll5 = [Roll(knockedDownPins: Array([Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5)])), Roll(knockedDownPins: [])]
        let strikeRoll = [Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))]
        let frames: [Frame] = [
            Frame(rolls: roll72, index: 1), Frame(rolls: strikeRoll, index: 2),
            Frame(rolls: openRoll5, index: 3), Frame(rolls: strikeRoll, index: 4),
            Frame(rolls: strikeRoll, index: 5)
        ]
        frames.enumerated().forEach { index, frame in
            game.frames[index].rolls = frame.rolls
        }
        
        printGameLog(game: game, maxScore: true)
        XCTAssertEqual(game.cumulativeScoreForFrame(at: 5), 59, "Cumulative score should be 59")
    }
}

class LastFrameTests: XCTestCase {
    func testLastFrame_StrikeStrikeStrike() {
        let game = Game(frames: [
            Frame(rolls: [], index: 1),
            Frame(rolls: [
                Roll.roll10,
                Roll.roll10,
                Roll.roll10
            ], index: 10)
        ])
        
        XCTAssertEqual(game.strikeCount, 3)
        XCTAssertEqual(game.spareCount, 0)
        XCTAssertEqual(game.openFrameCount, 0)
    }
    
    func testLastFrame_StrikeStrikeNine() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll.roll10,
                Roll.roll10,
                Roll.roll9
            ], index: 10)
        ])
        
        XCTAssertEqual(game.strikeCount, 2)
        XCTAssertEqual(game.spareCount, 0)
        XCTAssertEqual(game.openFrameCount, 0)
    }
    
    func testLastFrame_StrikeNineSpare() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll.roll10,
                Roll.roll9,
                Roll.roll1
            ], index: 10)
        ])
        
        XCTAssertEqual(game.strikeCount, 1)
        XCTAssertEqual(game.spareCount, 1)
        XCTAssertEqual(game.openFrameCount, 0)
    }
    
    func testLastFrame_NineSpareStrike() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll.roll9,
                Roll.roll1,
                Roll.roll10
            ], index: 10)
        ])
        
        XCTAssertEqual(game.strikeCount, 1)
        XCTAssertEqual(game.spareCount, 1)
        XCTAssertEqual(game.openFrameCount, 0)
    }

    func testLastFrame_NineSpareFive() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll.roll9,
                Roll.roll1,
                Roll.roll5
            ], index: 10)
        ])
        
        XCTAssertEqual(game.strikeCount, 0)
        XCTAssertEqual(game.spareCount, 1)
        XCTAssertEqual(game.openFrameCount, 0)
    }

    func testLastFrame_NineZero() {
        let game = Game(frames: [
            Frame(rolls: [
                Roll.roll9,
                Roll.roll0
            ], index: 10)
        ])
        
        XCTAssertEqual(game.strikeCount, 0)
        XCTAssertEqual(game.spareCount, 0)
        XCTAssertEqual(game.openFrameCount, 1)
    }
}
