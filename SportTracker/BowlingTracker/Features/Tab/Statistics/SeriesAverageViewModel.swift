import Combine

class SeriesAverageViewModel: ObservableObject {
    @Published var series = [Series]() {
        didSet {
            setup(for: series)
        }
    }
    
    @Published var averages: [Double] = []
    @Published var maxAverage: Double = 0.0
    @Published var minAverage: Double = 0.0
    @Published var averageRange: Double = 0.0

    private var cancellables: Set<AnyCancellable> = []
    
    init(series: [Series]) {
        self.series = series.sorted(by: { $0.date < $1.date })
    }
    
    func setup(for series: [Series]) {
        averages = series.sorted(by: { $0.date < $1.date }).map { $0.getSeriesAvarage() }
        maxAverage = averages.max() ?? 0
        minAverage = averages.min() ?? 0
        averageRange = maxAverage - minAverage
    }

    deinit {
        cancellables.removeAll()
    }
}
