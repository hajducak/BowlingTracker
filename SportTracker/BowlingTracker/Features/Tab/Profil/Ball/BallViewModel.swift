import Combine
import Foundation

enum BallViewContentType {
    case info
    case statistics
}

final class BallViewModel: TooltipViewModel, Identifiable {
    private var cancellables: Set<AnyCancellable> = []
    private let userService: UserService
    
    let ball: Ball
    var onDismiss: (() -> Void)?
    @Published var toast: Toast?
    @Published var contentType: BallViewContentType = .info // FIXME: not using this
    
    // MARK: - Ball Info
    @Published var name: String
    @Published var imageUrl: URL?
    @Published var coreImageUrl: URL?
    @Published var brand: String?
    @Published var coverstock: String?
    @Published var core: String?
    @Published var surface: String?
    @Published var rg: Double?
    @Published var diff: Double?
    @Published var weight: Int
    @Published var layout: String?
    @Published var lenght: Int?
    @Published var backend: Int?
    @Published var hook: Int?

    // MARK: - Ball statistics
    @Published var totalGames: Int = 0
    @Published var totalAverage: Double?
    @Published var strikeAfterStrikePercentage: Double?
    @Published var strikeAfterOpenPercentage: Double?
    @Published var firstBallAverage: Double?
    @Published var totalStrikesPercentage: Double?
    @Published var totalSparesPercentage: Double?
    @Published var totalOpensPercentage: Double?
    @Published var totalSplitsPercentage: Double?
    @Published var splitConversionPercentage: Double?
    @Published var cleanGamePercentage: Double?
    @Published var totalStrikesCount: String = ""
    @Published var totalSparesCount: String = ""
    @Published var totalOpensCount: String = ""
    @Published var totalSplitsCount: String = ""
    @Published var splitConversionCount: String = ""
    @Published var cleanGameCount: String = ""
    
    var pinCoverageViewModel: PinCoverageViewModel?
    
    init(userService: UserService, ball: Ball, onDismiss: (() -> Void)? = nil ) {
        self.ball = ball
        self.onDismiss = onDismiss
        self.userService = userService
        
        self.name = ball.name
        self.imageUrl = ball.imageUrl
        self.coreImageUrl = ball.coreImageUrl
        self.brand = ball.brand
        self.coverstock = ball.coverstock
        self.core = ball.core
        self.surface = ball.surface
        self.rg = ball.rg
        self.diff = ball.diff
        self.weight = ball.weight
        self.layout = ball.layout
        self.lenght = ball.lenght
        self.backend = ball.backend
        self.hook = ball.hook
    }
    
    func loadStatistics() {
        userService.fetchUserData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                let filteredGames: [Game] = user?.series
                    .flatMap { $0.games }
                    .filter { game in
                        if self.ball.isSpareBall ?? false {
                            return game.spareBallId == self.ball.id
                        } else {
                            return game.ballId == self.ball.id
                        }
                    } ?? []
                let filteredSeries: [Series] = user?.series.map { series in
                    var filtered = series
                    filtered.games = series.games.filter { game in
                        if self.ball.isSpareBall ?? false {
                            return game.spareBallId == self.ball.id
                        } else {
                            return game.ballId == self.ball.id
                        }
                    }
                    return filtered
                }
                .filter { !$0.games.isEmpty } ?? []
                self.setupStatistics(for: filteredGames, for: filteredSeries)
            }
            .store(in: &cancellables)
    }

    private func setupStatistics(for games: [Game], for series: [Series]) {
        if ball.isSpareBall ?? false {
            setupSapreBallStatistics(for: games, for: series)
        } else {
            setupStrikeBallStatistics(for: games)
        }
    }
    
    private func setupStrikeBallStatistics(for games: [Game]) {
        totalGames = games.count
        let totalScore = games.reduce(0) { $0 + $1.currentScore }
        totalAverage = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0
        
        pinCoverageViewModel = nil
        
        firstBallAverage = calculateFirstBallAverage(for: games)
        
        strikeAfterStrikePercentage = calculateStrikeAfterStrikePercentage(for: games)
        strikeAfterOpenPercentage = calculateStrikeAfterOpenPercentage(for: games)
        
        let strikesPossibility = 12 * totalGames
        let totalStrikes = games.reduce(0) { $0 + $1.strikeCount }
        
        let splitsPossibility = 10 * totalGames
        let totalSplits = games.reduce(0) { $0 + $1.splitCount }

        let percent = { (count: Int, total: Int) -> Double in
            total > 0 ? (Double(count) / Double(total)) * 100 : 0.0
        }
        
        splitConversionPercentage = nil
        cleanGamePercentage = nil
        
        totalSparesPercentage = nil
        totalOpensPercentage = nil
        totalStrikesPercentage = percent(totalStrikes, strikesPossibility)
        totalSplitsPercentage = percent(totalSplits, splitsPossibility)

        totalStrikesCount = "\(totalStrikes)/\(strikesPossibility)"
        totalSplitsCount = "\(totalSplits)/\(splitsPossibility)"
    }
    
    private func setupSapreBallStatistics(for games: [Game], for series: [Series]) {
        totalGames = games.count
        totalAverage = nil

        if pinCoverageViewModel == nil {
            pinCoverageViewModel = .init(series: series)
        } else {
            pinCoverageViewModel?.series = series
        }
        
        firstBallAverage = nil
        
        strikeAfterStrikePercentage = nil
        strikeAfterOpenPercentage = nil
        
        let opensPossibility = 10 * totalGames
        let totalOpenFrames = games.reduce(0) { $0 + $1.openFrameCount }
        let totalSpares = games.reduce(0) { $0 + $1.spareCount }
        let sparesPossibility = totalOpenFrames + totalSpares
        
        let percent = { (count: Int, total: Int) -> Double in
            total > 0 ? (Double(count) / Double(total)) * 100 : 0.0
        }

        calculateSplitConversion(for: series)
        calculateCleanGamePercentage(for: games)
            
        totalSparesPercentage = percent(totalSpares, sparesPossibility)
        totalOpensPercentage = percent(totalOpenFrames, opensPossibility)
        totalStrikesPercentage = nil
        totalSplitsPercentage = nil
        
        totalSparesCount = "\(totalSpares)/\(sparesPossibility)"
        totalOpensCount = "\(totalOpenFrames)/\(opensPossibility)"
    }
    
    private func calculateStrikeAfterStrikePercentage(for allGames: [Game]) -> Double {
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
        
        return totalStrikes > 0 ? (Double(strikeAfterStrikeCount) / Double(totalStrikes) * 100) : 0.0
    }
    
    private func calculateStrikeAfterOpenPercentage(for allGames: [Game]) -> Double {
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
        
         return totalOpenFrames > 0 ? (Double(strikeAfterOpenCount) / Double(totalOpenFrames) * 100) : 0.0
    }
    
    private func calculateFirstBallAverage(for allGames: [Game]) -> Double {
        let totalFirstBallPins = allGames
            .flatMap { $0.frames }
            .compactMap { $0.rolls.first }
            .reduce(0) { $0 + $1.knockedDownPins.count }
        
        let totalFirstBalls = allGames.count * 10
        
        return totalFirstBalls > 0 ? Double(totalFirstBallPins) / Double(totalFirstBalls) : 0.0
    }
    
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
    
    private func calculateCleanGamePercentage(for allGames: [Game]) {
        let cleanGames = allGames.filter { $0.isCleanGame }.count
        let totalGames = allGames.count
        
        cleanGameCount = "\(cleanGames)/\(totalGames)"
        cleanGamePercentage = totalGames > 0 ? (Double(cleanGames) / Double(totalGames) * 100) : 0.0
    }
    
    enum StatType {
        case strikeAfterStrike, strikeAfterOpen, firstBallAverage, strikes, spares, splits, splitConversion, opens, cleanGame
    }

    func showTooltip(for stat: StatType) {
        let text = getTooltipFor(stat)
        super.showTooltip(text: text)
    }

    internal func getTooltipFor(_ stat: StatType) -> String {
        switch stat {
        case .strikes:
            return "Percentage of all possible strikes thrown (12 per game), where 100% means all strikes."
        case .spares:
            return "Percentage of remaining frames converted to spares after first throw, where 100% means all non-strike frames were spared."
        case .strikeAfterStrike:
            return "Percentage of strikes thrown in the frame following a strike."
        case .strikeAfterOpen:
            return "Percentage of strikes thrown in the frame following an open frame."
        case .firstBallAverage:
            return "Average number of pins knocked down on the first ball of each frame."
        case .opens:
            return "Percentage of frames where pins remained standing after both throws, lower is better."
        case .splits:
            return "Percentage of frames where a split occurred, lower is better."
        case .splitConversion:
            return "Percentage of splits that were converted to spares."
        case .cleanGame:
            return "Percentage of games with no open frames."
        }
    }

    func close() {
        onDismiss?()
    }

    deinit {
        cancellables.removeAll()
    }
}
