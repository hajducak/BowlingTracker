import Combine

class SeriesAverageViewModel: ObservableObject {
    @Published var series = [Series]() {
        didSet {
            setup(for: series.sorted(by: { $0.date < $1.date }))
        }
    }
    
    @Published var averages: [Double] = []
    @Published var maxAverage: Double = 0.0
    @Published var minAverage: Double = 0.0
    @Published var totalAverage: Double = 0.0

    private var cancellables: Set<AnyCancellable> = []
    
    init(series: [Series]) {
        self.series = series.sorted(by: { $0.date < $1.date })
    }
    
    func setup(for series: [Series]) {
        averages = series.filter({ !$0.games.isEmpty }).map { $0.getSeriesAverage() }
        maxAverage = averages.max() ?? 0
        minAverage = averages.min() ?? 0

        let totalScore = series.reduce(0) { $0 + $1.getSeriesScore() }
        let totalGames = series.reduce(0) { $0 + $1.games.count }
        totalAverage = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0
    }

    deinit {
        cancellables.removeAll()
    }
}
