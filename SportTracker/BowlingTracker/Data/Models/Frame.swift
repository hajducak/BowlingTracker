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

    /// Used for formating splits in individual frame Rolls colums
    func isSplitRoll(for index: Int) -> Bool {
        guard let firstRoll = rolls.first else { return false }
        guard self.index != 10 else {
            switch index {
            case 0: return firstRoll.isSplitRoll
            case 1: return firstRoll.knockedDownPins.count == 10 && rolls[1].isSplitRoll || !firstRoll.isSplitRoll && rolls[1].isSplitRoll
            case 2: return firstRoll.knockedDownPins.count + rolls[1].knockedDownPins.count == 20 && rolls[2].isSplitRoll || rolls[2].isSplitRoll && !rolls[1].isSplitRoll
            default: return false
            }
        }
        return index == 0 ? firstRoll.isSplitRoll : false
    }
    var isSplitFrame: Bool {
        rolls.contains { $0.isSplitRoll }
    }
}
