import Foundation

struct Pin: Hashable {
    let id: Int
}

struct Roll {
    let knockedDownPins: Set<Pin>
}

enum FrameType {
    case strike
    case spare
    case open
}

struct Frame {
    var rolls: [Roll] = []
    var frameType: FrameType? {
        if rolls.count == 1, rolls.first?.knockedDownPins.count == 10 {
            return .strike
        } else if rolls.count >= 2, rolls[0].knockedDownPins.count + rolls[1].knockedDownPins.count == 10 {
            return .spare
        } else {
            return .open
        }
    }
}

struct Game {
    var frames: [Frame] = []
    
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
        let strikeRoll = Roll(knockedDownPins: Set((1...10).map { Pin(id: $0) }))
        while tempFrames.count < 9 {
            tempFrames.append(Frame(rolls: [strikeRoll]))
        }
        let finalFrame = Frame(rolls: [strikeRoll, strikeRoll, strikeRoll])
        tempFrames.append(finalFrame)
        return Game(frames: tempFrames).currentScore
    }
    
    var totalScore: Int? {
        return frames.count == 10 ? currentScore : nil
    }
}
