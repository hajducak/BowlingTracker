import Foundation
import Combine

class StatisticsViewModel: ObservableObject, Identifiable {
    @Published var totalGames: Int = 0
    var basicStatisticsViewModel: BasicStatisticsViewModel?
    var advancedStaticticsViewModel: AdvancedStatisticsViewModel?
    var averagesViewModel: SeriesAverageViewModel?
    var pinCoverageViewModel: PinCoverageViewModel?
    @Published var selectedFilter: SeriesType?
    @Published var isLoading: Bool = false
    @Published var toast: Toast?

    private let userService: UserService
    private var series: [Series] = []
    private var filteredSeries: [Series] = []
    private var cancellables: Set<AnyCancellable> = []

    init(userService: UserService) {
        self.userService = userService
        setUp()
        setupFiltering()

        NotificationCenter.default.addObserver(self, selector: #selector(setUp), name: .seriesDidSave, object: nil)
    }

    @objc private func setUp() {
        isLoading = true
        userService.fetchUserData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
                isLoading = false
            } receiveValue: { [weak self] user in
                guard let self = self, let userData = user else { return }
                filteredSeries = userData.series
                self.series = userData.series
                selectedFilter = nil
                applyFilter()
            }.store(in: &cancellables)
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
    
    private func setupStatistics(for series: [Series]) {
        totalGames = series.reduce(0) { $0 + $1.games.count }
        if basicStatisticsViewModel == nil  {
            basicStatisticsViewModel = .init(series: series)
        } else {
            basicStatisticsViewModel?.series = series
        }
        if averagesViewModel == nil {
            averagesViewModel = .init(series: series)
        } else {
            averagesViewModel?.series = series
        }
        if advancedStaticticsViewModel == nil {
            advancedStaticticsViewModel = .init(series: series)
        } else {
            advancedStaticticsViewModel?.series = series
        }
        if pinCoverageViewModel == nil {
            pinCoverageViewModel = .init(series: series)
        } else {
            pinCoverageViewModel?.series = series
        }
        // MARK: - More Statistics:
        // TODO: Ball usage percentage - ball name in game
        // TODO: Bowling house center statistics
        // TODO: lane number statictics
    }
    
    func refresh() {
        setUp()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .seriesDidSave, object: nil)
        cancellables.removeAll()
        
        basicStatisticsViewModel = nil
        advancedStaticticsViewModel = nil
        averagesViewModel = nil
        pinCoverageViewModel = nil
    }
}
