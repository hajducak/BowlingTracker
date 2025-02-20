import Foundation
struct Game: Codable, Identifiable {
    var id: String = UUID().uuidString
    var frames: [Frame]

    init(frames: [Frame] = []) {
        self.frames = frames.isEmpty ? (1...10).map { Frame(rolls: [], index: $0) } : frames
    }

    mutating func addRoll(knockedDownPins: [Pin]) {
        let roll = Roll(knockedDownPins: knockedDownPins)

        if let unfinishedFrameIndex = frames.firstIndex(where: { $0.frameType == .unfinished }) {
            frames[unfinishedFrameIndex].rolls.append(roll)
        }
    }
    
    var strikeCount: Int {
        return frames.filter { $0.frameType == .strike }.count
    }
    
    var spareCount: Int {
        return frames.filter { $0.frameType == .spare }.count
    }
    
    var openFrameCount: Int {
        return frames.filter { $0.frameType == .open }.count
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
}
