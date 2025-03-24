import Combine

class AdvancedStatisticsViewModel: ObservableObject {
    @Published var series = [Series]() {
        didSet {
            setup(for: series)
        }
    }
    
    @Published var firstBallAverage: Double = 0.0
    @Published var strikeAfterStrikePercentage: Double = 0.0
    @Published var strikeAfterOpenPercentage: Double = 0.0
    @Published var cleanGameCount: String = ""
    @Published var cleanGamePercentage: Double = 0.0
    @Published var splitConversionCount: String = ""
    @Published var splitConversionPercentage: Double = 0.0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(series: [Series]) {
        self.series = series
    }
    
    func setup(for series: [Series]) {
        calculateFirstBallAverage(for: series)
        calculateStrikeAfterStrikePercentage(for: series)
        calculateStrikeAfterOpenPercentage(for: series)
        calculateCleanGamePercentage(for: series)
        calculateSplitConversion(for: series)
    }

    /// How many pins you're knocking down on average on 1st ball in a frame.
    private func calculateFirstBallAverage(for series: [Series]) {
        let totalFirstBallPins = series.flatMap { $0.games }
            .flatMap { $0.frames }
            .compactMap { $0.rolls.first }
            .reduce(0) { $0 + $1.knockedDownPins.count }
        
        let totalFirstBalls = series.reduce(0) { $0 + $1.games.count } * 10
        
        firstBallAverage = totalFirstBalls > 0 ? Double(totalFirstBallPins) / Double(totalFirstBalls) : 0.0
    }
    
    /// How many strikes you're knocking down on average after strike frame.
    private func calculateStrikeAfterStrikePercentage(for series: [Series]) {
        let allGames = series.flatMap { $0.games }
        
        let (strikeAfterStrikeCount, totalStrikes) = allGames.reduce((0, 0)) { result, game in
            let frames = game.frames
            let (count, total) = (0..<frames.count-1).reduce((0, 0)) { frameResult, index in
                let previousFrame = frames[index]
                let currentFrame = frames[index + 1]
                
                if previousFrame.frameType == .strike {
                    return (
                        frameResult.0 + (currentFrame.frameType == .strike ? 1 : 0),
                        frameResult.1 + 1
                    )
                }
                return frameResult
            }
            
            return (result.0 + count, result.1 + total)
        }
        
        strikeAfterStrikePercentage = totalStrikes > 0 ? (Double(strikeAfterStrikeCount) / Double(totalStrikes) * 100) : 0.0
    }
    
    /// How many strikes you're knocking down on average after open frame.
    private func calculateStrikeAfterOpenPercentage(for series: [Series]) {
        let allGames = series.flatMap { $0.games }
        
        let (strikeAfterOpenCount, totalOpenFrames) = allGames.reduce((0, 0)) { result, game in
            let frames = game.frames
            let (count, total) = (0..<frames.count-1).reduce((0, 0)) { frameResult, index in
                let previousFrame = frames[index]
                let currentFrame = frames[index + 1]
                
                if previousFrame.frameType == .open {
                    return (
                        frameResult.0 + (currentFrame.frameType == .strike ? 1 : 0),
                        frameResult.1 + 1
                    )
                }
                return frameResult
            }
            
            return (result.0 + count, result.1 + total)
        }
        
        strikeAfterOpenPercentage = totalOpenFrames > 0 ? (Double(strikeAfterOpenCount) / Double(totalOpenFrames) * 100) : 0.0
    }
    
    private func calculateCleanGamePercentage(for series: [Series]) {
        let allGames = series.flatMap { $0.games }
        let cleanGames = allGames.filter { $0.isCleanGame }.count
        let totalGames = allGames.count
        
        cleanGameCount = "\(cleanGames)/\(totalGames)"
        cleanGamePercentage = totalGames > 0 ? (Double(cleanGames) / Double(totalGames) * 100) : 0.0
    }
    
    /// How many splits you're knocking down on average.
    private func calculateSplitConversion(for series: [Series]) {
        let allGames = series.flatMap { $0.games }
        
        let (converted, total) = allGames.reduce((0, 0)) { result, game in
            let (gameConverted, gameTotal) = game.frames.reduce((0, 0)) { frameResult, frame in
                if frame.isSplitFrame {
                    return (
                        frameResult.0 + (frame.frameType == .spare ? 1 : 0),
                        frameResult.1 + 1
                    )
                }
                return frameResult
            }
            
            return (result.0 + gameConverted, result.1 + gameTotal)
        }

        splitConversionCount = "\(converted)/\(total)"
        splitConversionPercentage = total > 0 ? (Double(converted) / Double(total) * 100) : 0.0
    }
}
