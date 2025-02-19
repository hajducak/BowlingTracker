struct Roll {
    let knockedDownPins: [Pin]
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
