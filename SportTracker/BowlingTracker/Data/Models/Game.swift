import Foundation
struct Game: Codable, Identifiable {
    var id: String = UUID().uuidString
    var frames: [Frame]
    var lane: String? = nil
    @available(*, deprecated, renamed: "ballId")
    var ball: String? = nil // TODO: remove this param from databaze (in all games)
    var ballId: String? = nil
    
    init(frames: [Frame] = []) {
        self.frames = frames.isEmpty ? (1...10).map { Frame(rolls: [], index: $0) } : frames
    }
    
    mutating func addRoll(knockedDownPins: [Pin]) {
        let roll = Roll(knockedDownPins: knockedDownPins)
        
        if let unfinishedFrameIndex = frames.firstIndex(where: { $0.frameType == .unfinished }) {
            frames[unfinishedFrameIndex].rolls.append(roll)
        }
    }

    mutating func undoRoll() {
        guard let lastFrameIndex = frames.lastIndex(where: { !$0.rolls.isEmpty }) else { return }
        frames[lastFrameIndex].rolls.removeLast()
    }
    
    var isCleanGame: Bool {
        let regularFrames = frames.dropLast()
        let hasOpenRegularFrames = regularFrames.contains { frame in
            frame.frameType == .open
        }
        if let lastFrame = frames.last {
            let isLastFrameClean = lastFrame.rolls.count == 3 && lastFrame.frameType == .last
            return !hasOpenRegularFrames && isLastFrameClean
        }
        return false
    }
    
    var strikeCount: Int {
        frames.filter { $0.frameType == .strike }.count + lastFrameCount().strikes
    }
    
    var spareCount: Int {
        frames.filter { $0.frameType == .spare }.count + lastFrameCount().spares
    }
    
    var openFrameCount: Int {
        frames.filter { $0.frameType == .open }.count + lastFrameCount().opens
    }
    
    var splitCount: Int {
        frames.filter { $0.isSplitFrame }.count
    }

    func lastFrameCount() -> (strikes: Int, spares: Int, opens: Int) {
        guard let lastFrame = frames.last, lastFrame.frameType == .last else {
            return (0, 0, 0)
        }
        
        let rolls = lastFrame.rolls.map { $0.knockedDownPins.count }
        let rollCount = rolls.count
        
        var strikes = 0
        var spares = 0
        var opens = 0

        if rollCount >= 1, rolls[0] == 10 {
            strikes += 1

            if rollCount >= 3, rolls[1] + rolls[2] == 10 {
                spares += 1
            } else {
                if rollCount >= 2, rolls[1] == 10 { strikes += 1 }
                if rollCount >= 3, rolls[2] == 10 { strikes += 1 }
            }
        } else if rollCount >= 2 {
            if rolls[0] + rolls[1] == 10 {
                spares += 1
                if rollCount == 3, rolls[2] == 10 { strikes += 1 }
            } else {
                opens += 1
            }
        }

        return (strikes, spares, opens)
    }

    var currentScore: Int {
        var score = 0
        for (index, frame) in frames.enumerated() {
            if index >= 10 { break }
            
            let frameScore = frame.rolls.reduce(0) { $0 + $1.knockedDownPins.count }
            score += frameScore
            
            if frame.frameType == .strike, index < frames.count - 1 {
                let nextFrame = frames[index + 1]
                score += nextFrame.rolls.prefix(2).reduce(0) { $0 + $1.knockedDownPins.count }
                
                if nextFrame.frameType == .strike, index + 2 < frames.count {
                    let secondNextFrame = frames[index + 2]
                    if let firstRoll = secondNextFrame.rolls.first {
                        score += firstRoll.knockedDownPins.count
                    }
                }
            } else if frame.frameType == .spare, index < frames.count - 1 {
                let nextFrame = frames[index + 1]
                if let firstRoll = nextFrame.rolls.first {
                    score += firstRoll.knockedDownPins.count
                }
            }
        }
        return score
    }
    
    var maxPossibleScore: Int {
        var tempFrames = frames
        let strikeRoll = Roll(knockedDownPins: Array((1...10).map { Pin(id: $0) }))

        tempFrames.enumerated().forEach { index, frame in
            if frame.frameType == .unfinished {
                tempFrames[index].rolls = index == 9 ? [strikeRoll, strikeRoll, strikeRoll] : [strikeRoll]
            }
        }
        
        return Game(frames: tempFrames).currentScore
    }
    
    /// Calculate score for current frame based on previous and next score
    /// - adding bonus for X
    /// - adding bonus for /
    private func scoreForFrame(at index: Int) -> Int {
        guard index >= 0, index < frames.count else { return 0 }
        
        var score = 0
        let frame = frames[index]
        
        // Sum the knocked-down pins in the current frame
        let frameScore = frame.rolls.reduce(0) { $0 + $1.knockedDownPins.count }
        score += frameScore
        
        // Strike Bonus Calculation
        if frame.frameType == .strike, index < frames.count - 1 {
            let nextFrame = frames[index + 1]
            score += nextFrame.rolls.prefix(2).reduce(0) { $0 + $1.knockedDownPins.count }
            
            // If consecutive strikes, take extra roll
            if nextFrame.frameType == .strike, index + 2 < frames.count {
                let secondNextFrame = frames[index + 2]
                if let firstRoll = secondNextFrame.rolls.first {
                    score += firstRoll.knockedDownPins.count
                }
            }
        }
        
        // Spare Bonus Calculation
        if frame.frameType == .spare, index < frames.count - 1 {
            let nextFrame = frames[index + 1]
            if let firstRoll = nextFrame.rolls.first {
                score += firstRoll.knockedDownPins.count
            }
        }
        
        return score
    }

    /// Use this in game view for cumulative sum of score so far
    func cumulativeScoreForFrame(at index: Int) -> Int {
        return (0...index).reduce(0) { $0 + scoreForFrame(at: $1) }
    }
}
