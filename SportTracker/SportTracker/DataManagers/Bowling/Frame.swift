enum FrameType: String {
    case strike
    case spare
    case open
    case last
    case unfinished
}

struct Frame: Codable {
    var rolls: [Roll] = []
    var frameType: FrameType {
        if rolls.count == 1, rolls.first?.knockedDownPins.count == 10, index != 10 {
            return .strike
        } else if rolls.count == 2, rolls[0].knockedDownPins.count + rolls[1].knockedDownPins.count == 10, index != 10 {
            return .spare
        } else if rolls.count == 2, rolls[0].knockedDownPins.count + rolls[1].knockedDownPins.count < 10, index != 10 {
            return .open
        } else {
            if (rolls.count == 3) || (rolls.count == 2 && rolls[0].knockedDownPins.count + rolls[1].knockedDownPins.count < 10) {
                return .last
            } else {
                return .unfinished
            }
        }
    }
    var index: Int
}
