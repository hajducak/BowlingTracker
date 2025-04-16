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
    @Published var isSpareBall: Bool
    // MARK: - Ball statistics
    @Published var totalGames: Int = 0
    @Published var totalAverage: Int = 0
    @Published var strikeAfterStrikePercentage: Double?
    @Published var strikeAfterOpenPercentage: Double?
    @Published var firstBallAverage: Double?
    
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
        self.isSpareBall = ball.isSpareBall ?? false
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

                self.setupStatistics(for: filteredGames)
            }
            .store(in: &cancellables)
    }
    
    private func setupStatistics(for games: [Game]) {
        totalGames = games.count
        let totalScore = games.reduce(0) { $0 + $1.currentScore }
        totalAverage = totalGames > 0 ? (totalScore / totalGames) : 0

        calculateStrikeAfterStrikePercentage(for: games)
        calculateStrikeAfterOpenPercentage(for: games)
        calculateFirstBallAverage(for: games)
        // TODO: add pin coverage
        // TODO: add two more graphs, strike and spare percentage? what I need to see on my ball
        // TODO: Diferent for spare ball
    }
    
    private func calculateStrikeAfterStrikePercentage(for allGames: [Game]) {
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
    
    private func calculateStrikeAfterOpenPercentage(for allGames: [Game]) {
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
    
    private func calculateFirstBallAverage(for allGames: [Game]) {
        let totalFirstBallPins = allGames
            .flatMap { $0.frames }
            .compactMap { $0.rolls.first }
            .reduce(0) { $0 + $1.knockedDownPins.count }
        
        let totalFirstBalls = allGames.count * 10
        
        firstBallAverage = totalFirstBalls > 0 ? Double(totalFirstBallPins) / Double(totalFirstBalls) : 0.0
    }
    
    enum StatType {
        case strikeAfterStrike, strikeAfterOpen, firstBallAverage
    }

    func showTooltip(for stat: StatType) {
        let text = getTooltipFor(stat)
        super.showTooltip(text: text)
    }

    internal func getTooltipFor(_ stat: StatType) -> String {
        switch stat {
        case .strikeAfterStrike:
            return "Percentage of strikes thrown in the frame following a strike."
        case .strikeAfterOpen:
            return "Percentage of strikes thrown in the frame following an open frame."
        case .firstBallAverage:
            return "Average number of pins knocked down on the first ball of each frame."
        }
    }

    func close() {
        onDismiss?()
    }

    deinit {
        cancellables.removeAll()
    }
}
