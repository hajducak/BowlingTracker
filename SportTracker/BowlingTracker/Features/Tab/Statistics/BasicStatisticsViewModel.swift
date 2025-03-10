import Foundation
import Combine

class BasicStatisticsViewModel: ObservableObject {
    @Published var series = [Series]() {
        didSet {
            setupStatistics(for: series)
        }
    }
    
    @Published var totalGames: Int = 0
    @Published var totalScore: Int = 0
    @Published var totalAvarage: Double = 0.0
    @Published var totalStrikesPercentage: Double = 0.0
    @Published var totalSparesPercentage: Double = 0.0
    @Published var totalOpensPercentage: Double = 0.0
    @Published var totalSplitsPercentage: Double = 0.0
    @Published var totalStrikesCount: String = ""
    @Published var totalSparesCount: String = ""
    @Published var totalOpensCount: String = ""
    @Published var totalSplitsCount: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(series: [Series]) {
        self.series = series
    }
    
    func setupStatistics(for series: [Series]) {
        totalScore = series.reduce(0) { $0 + $1.getSeriesScore() }
        totalGames = series.reduce(0) { $0 + $1.games.count }
        
        let strikesPossibility = 12 * totalGames
        let totalStrikes = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.strikeCount } }
        
        let sparesPossibility = 10 * totalGames
        let totalSpares = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.spareCount } }
        
        let opensPossibility = 10 * totalGames
        let totalOpenFrames = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.openFrameCount } }
        
        let splitsPossibility = 10 * totalGames
        let totalSplits = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.splitCount } }

        totalAvarage = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0

        let percent = { (count: Int, total: Int) -> Double in
            total > 0 ? (Double(count) / Double(total)) * 100 : 0.0
        }

        totalStrikesPercentage = percent(totalStrikes, strikesPossibility)
        totalSparesPercentage = percent(totalSpares, sparesPossibility)
        totalOpensPercentage = percent(totalOpenFrames, opensPossibility)
        totalSplitsPercentage = percent(totalSplits, splitsPossibility)

        totalStrikesCount = "\(totalStrikes)/\(strikesPossibility)"
        totalSparesCount = "\(totalSpares)/\(sparesPossibility)"
        totalOpensCount = "\(totalOpenFrames)/\(opensPossibility)"
        totalSplitsCount = "\(totalSplits)/\(splitsPossibility)"
    }
}
