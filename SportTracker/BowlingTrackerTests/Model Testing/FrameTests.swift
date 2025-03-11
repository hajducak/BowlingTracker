import XCTest
@testable import BowlingTracker

final class FrameTests: XCTestCase {

    func testIsSplitRoll() {
        let splitFrame = Frame(rolls: [Roll.init(knockedDownPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 8), Pin(id: 9)])], index: 1)
        let nonSplitFrame = Frame(rolls: [Roll.init(knockedDownPins: [Pin(id: 1)])], index: 1)
        
        XCTAssertTrue(splitFrame.isSplitRoll(for: 0), "Frame should be recognized as a split roll")
        XCTAssertFalse(nonSplitFrame.isSplitRoll(for: 1), "Frame should not be recognized as a split roll")
    }
    
    func testFrameType() {
        let strikeFrame = Frame(rolls: [Roll.roll10], index: 1)
        XCTAssertEqual(strikeFrame.frameType, .strike, "Frame should be recognized as a strike")
        
        let spareFrame = Frame(rolls: [Roll.roll2, Roll.roll8], index: 1)
        XCTAssertEqual(spareFrame.frameType, .spare, "Frame should be recognized as a spare")
        
        let openFrame = Frame(rolls: [Roll.roll1, Roll.roll2], index: 1)
        XCTAssertEqual(openFrame.frameType, .open, "Frame should be recognized as an open frame")
    }
}
