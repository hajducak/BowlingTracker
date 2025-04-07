import Combine

class PinCoverageViewModel: ObservableObject {
    @Published var series = [Series]() {
        didSet {
            setup(for: series)
        }
    }
    @Published var coveragePercentage: Double = 0.0
    @Published var coverageCount: String = ""
    @Published var selectedPinIds: Set<Int> = [] {
        didSet {
            calculateCoverage()
        }
    }
    @Published var disabledPinIds: Set<Int> = []
    
    init(series: [Series]) {
        self.series = series
    }
    
    private func setup(for series: [Series]) {
        let pinCombination = selectedPinIds.map { Pin(id: $0) }
        calculateCoverage(for: pinCombination, series)
    }

    private func calculateCoverage() {
        let pinCombination = selectedPinIds.map { Pin(id: $0) }
        calculateCoverage(for: pinCombination, series)
    }
    
    /// Calculates coverage percentage for a specific pin combination
    /// - Parameter pinCombination: Array of pins that should be left standing
    private func calculateCoverage(for pinCombination: [Pin],_ series: [Series]) {
        guard !pinCombination.isEmpty else {
            coverageCount = "0/0"
            coveragePercentage = 0.0
            return
        }
        let allGames = series.flatMap { $0.games }
        
        let (successful, total) = allGames.reduce((0, 0)) { result, game in
            let (gameSuccessful, gameTotal) = game.frames.reduce((0, 0)) { frameResult, frame in
                // Check if this frame has the exact pin combination we're looking for
                if let firstRoll = frame.rolls.first,
                   hasExactPinCombination(firstRoll.knockedDownPins, pinCombination) {
                    // If we found the combination, check if it was covered in the second roll
                    let wasCovered = frame.rolls.count > 1 &&
                        frame.rolls[1].knockedDownPins.count == pinCombination.count &&
                        Set(frame.rolls[1].knockedDownPins.map { $0.id }) == Set(pinCombination.map { $0.id })
                    return (
                        frameResult.0 + (wasCovered ? 1 : 0),
                        frameResult.1 + 1
                    )
                }
                return frameResult
            }
            
            return (result.0 + gameSuccessful, result.1 + gameTotal)
        }
        
        coverageCount = "\(successful)/\(total)"
        coveragePercentage = total > 0 ? (Double(successful) / Double(total) * 100) : 0.0
    }
    
    /// Checks if the knocked down pins match exactly with the pin combination we're looking for
    private func hasExactPinCombination(_ knockedDownPins: [Pin], _ targetCombination: [Pin]) -> Bool {
        // Create set of all possible pin IDs (1-10)
        let allPinIds = Set(1...10)
        
        // Create set of target pin IDs that should be left standing
        let targetIds = Set(targetCombination.map { $0.id })
        
        // Create set of pins that should be knocked down (all pins except target)
        let expectedKnockedDownIds = allPinIds.subtracting(targetIds)
        
        // Create set of actually knocked down pin IDs
        let knockedDownIds = Set(knockedDownPins.map { $0.id })
        
        // Check if the knocked down pins match exactly what we expect
        return knockedDownIds == expectedKnockedDownIds
    }
}
