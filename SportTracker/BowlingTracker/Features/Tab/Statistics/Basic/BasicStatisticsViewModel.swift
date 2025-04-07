import Foundation
import Combine

class BasicStatisticsViewModel: TooltipViewModel, TooltipStatRepresentable {
    @Published var series = [Series]() {
        didSet {
            setupStatistics(for: series)
        }
    }
    
    @Published var totalGames: Int = 0
    @Published var totalScore: Int = 0
    @Published var totalAverage: Double = 0.0
    @Published var totalStrikesPercentage: Double = 0.0
    @Published var totalSparesPercentage: Double = 0.0
    @Published var totalOpensPercentage: Double = 0.0
    @Published var totalSplitsPercentage: Double = 0.0
    @Published var totalStrikesCount: String = ""
    @Published var totalSparesCount: String = ""
    @Published var totalOpensCount: String = ""
    @Published var totalSplitsCount: String = ""
    
    init(series: [Series]) {
        self.series = series
    }
    
    func setupStatistics(for series: [Series]) {
        totalScore = series.reduce(0) { $0 + $1.getSeriesScore() }
        totalGames = series.reduce(0) { $0 + $1.games.count }
        
        let strikesPossibility = 12 * totalGames
        let totalStrikes = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.strikeCount } }

        let opensPossibility = 10 * totalGames
        let totalOpenFrames = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.openFrameCount } }
        
        let totalSpares = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.spareCount } }
        let sparesPossibility = totalOpenFrames + totalSpares
        
        let splitsPossibility = 10 * totalGames
        let totalSplits = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.splitCount } }

        totalAverage = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0

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

    enum StatType {
        case strikes, spares, opens, splits
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
        case .opens:
            return "Percentage of frames where pins remained standing after both throws, lower is better."
        case .splits:
            return "Percentage of frames where a split occurred, lower is better."
        }
    }
}
