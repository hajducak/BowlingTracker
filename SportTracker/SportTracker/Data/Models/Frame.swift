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

    var isSplitFrame: Bool {
        guard let firstRoll = rolls.first else { return false }
        let knockedDownPinIDs = Set(firstRoll.knockedDownPins.map { $0.id })
        let allPins: Set<Int> = Set(1...10)
        let standingPins = allPins.subtracting(knockedDownPinIDs)
        
        let splitCombinations: Set<Set<Int>> = [
            [7, 10], [7, 9], [8, 10], [4, 6], [5, 7], [4, 9], [5, 10], [5, 7, 10], [3, 7],
            [2, 10], [3, 10], [2, 7], [4, 7, 10], [6, 7, 10], [4, 9], [6, 8],
            [4, 6, 7, 10], [4, 6, 7, 8, 10], [4, 6, 7, 9, 10], [7, 6, 9, 10], [7, 8, 4, 10],
            [3, 4, 6, 7, 10], [2, 4, 6, 7, 10], [2, 4, 6, 7, 8, 10], [3, 4, 6, 7, 9, 10]
        ]
        
        return splitCombinations.contains(standingPins)
    }
}
