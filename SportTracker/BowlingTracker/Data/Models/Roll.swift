struct Roll: Codable, Hashable {
    let knockedDownPins: [Pin]
}

extension Roll {
    var isSplitRoll: Bool {
        let knockedDownPinIDs = Set(self.knockedDownPins.map { $0.id })
        let allPins: Set<Int> = Set(1...10)
        let standingPins = allPins.subtracting(knockedDownPinIDs)
        
        let splitCombinations: Set<Set<Int>> = [
            [7, 10], [7, 6], [7, 9], [8, 10], [4, 6], [4, 10], [5, 7], [4, 9], [5, 10], [3, 7], [4, 9], [6, 8], [2, 7], [2, 10], [3, 10],
            [5, 7, 10], [2, 8, 10], [4, 7, 6], [4, 7, 10], [6, 7, 10],
            [4, 6, 7, 10], [7, 6, 9, 10], [7, 8, 4, 10], [2, 8, 4, 10], [7, 4, 9, 6],
            [4, 6, 7, 9, 10], [3, 4, 6, 7, 10], [2, 4, 6, 7, 10], [4, 6, 7, 8, 10],
            [2, 4, 6, 7, 8, 10], [3, 4, 6, 7, 9, 10]
        ]
        
        return splitCombinations.contains(standingPins)
    }
}

extension Roll {
    static let tenPins = Array((1...10).map { Pin(id: $0) })
    static let ninePins = Array((1...9).map { Pin(id: $0) })
    static let eightPins = Array((1...8).map { Pin(id: $0) })
    static let sevenPins = Array((1...7).map { Pin(id: $0) })
    static let sixPins = Array((1...6).map { Pin(id: $0) })
    static let fivePins = Array((1...5).map { Pin(id: $0) })
    static let fourPins = Array((1...4).map { Pin(id: $0) })
    static let threePins = Array((1...3).map { Pin(id: $0) })
    static let twoPins = Array((1...2).map { Pin(id: $0) })
    static let onePins = Array((1...1).map { Pin(id: $0) })
}

extension Roll {
    static var roll10 = Roll.init(knockedDownPins: Roll.tenPins)
    static var roll9 = Roll.init(knockedDownPins: Roll.ninePins)
    static var roll8 = Roll.init(knockedDownPins: Roll.eightPins)
    static var roll7 = Roll.init(knockedDownPins: Roll.sevenPins)
    static var roll6 = Roll.init(knockedDownPins: Roll.sixPins)
    static var roll5 = Roll.init(knockedDownPins: Roll.fivePins)
    static var roll4 = Roll.init(knockedDownPins: Roll.fourPins)
    static var roll3 = Roll.init(knockedDownPins: Roll.threePins)
    static var roll2 = Roll.init(knockedDownPins: Roll.twoPins)
    static var roll1 = Roll.init(knockedDownPins: Roll.onePins)
    static var roll0 = Roll.init(knockedDownPins: [])
}
