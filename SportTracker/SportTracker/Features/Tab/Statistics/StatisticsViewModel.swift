import Foundation
import Combine

class StatisticsViewModel: ObservableObject, Identifiable {
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
    
    @Published var selectedFilter: SeriesType?
    @Published var isLoading: Bool = false
    @Published var toast: Toast?

    private let firebaseManager: FirebaseManager
    private var series: [Series] = []
    private var filteredSeries: [Series] = []
    private var cancellables: Set<AnyCancellable> = []

    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
        setUp()
        setupFiltering()
    }

    func setUp() {
        isLoading = true
        firebaseManager.fetchAllSeries()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] series in
                guard let self else { return }
                filteredSeries = series
                self.series = series
                selectedFilter = nil
                applyFilter()
            }
            .store(in: &cancellables)
    }
    
    private func setupFiltering() {
        $selectedFilter
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilter()
            }
            .store(in: &cancellables)
    }
    
    private func applyFilter() {
        let filteredSeries = selectedFilter == nil ?
            series : series.filter { $0.tag == selectedFilter }
        self.filteredSeries = filteredSeries.sorted(by: { $0.date > $1.date })
        setupStatistics(for: filteredSeries)
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
        
        let spolitsPossibility = 10 * totalGames
        let totalSplits = series.reduce(0) { $0 + $1.games.reduce(0) { $0 + $1.splitCount } }

        totalAvarage = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0

        let percent = { (count: Int, total: Int) -> Double in
            total > 0 ? (Double(count) / Double(total)) * 100 : 0.0
        }

        totalStrikesPercentage = percent(totalStrikes, strikesPossibility)
        totalSparesPercentage = percent(totalSpares, sparesPossibility)
        totalOpensPercentage = percent(totalOpenFrames, opensPossibility)
        totalSplitsPercentage = percent(totalSplits, spolitsPossibility)

        totalStrikesCount = "\(totalStrikes)/\(strikesPossibility)"
        totalSparesCount = "\(totalSpares)/\(sparesPossibility)"
        totalOpensCount = "\(totalOpenFrames)/\(opensPossibility)"
        totalSplitsCount = "\(totalSplits)/\(spolitsPossibility)"
        
        // TODO: add 10 pin covarage % (maybe some more combination of pins, % of their covarage)
    }
}
