import Foundation
import Combine

class StatisticsViewModel: ObservableObject, Identifiable {
    @Published var totalGames: Int = 0
    var basicStatisticsViewModel: BasicStatisticsViewModel?
    var averagesViewModel: SeriesAverageViewModel?
    @Published var selectedFilter: SeriesType?
    @Published var isLoading: Bool = false
    @Published var toast: Toast?

    private let firebaseService: FirebaseService<Series>
    private var series: [Series] = []
    private var filteredSeries: [Series] = []
    private var cancellables: Set<AnyCancellable> = []

    init(firebaseService: FirebaseService<Series>) {
        self.firebaseService = firebaseService
        setUp()
        setupFiltering()

        NotificationCenter.default.addObserver(self, selector: #selector(setUp), name: .seriesDidSave, object: nil)
    }

    @objc private func setUp() {
        isLoading = true
        firebaseService.fetchAll()
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
    
    private func setupStatistics(for series: [Series]) {
        totalGames = series.reduce(0) { $0 + $1.games.count }
        // MARK: - Basic Statistics:
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
        // MARK: - more Statistics
        // TODO: add 10 pin covarage % (maybe some more combination of pins, % of their covarage)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .seriesDidSave, object: nil)
        cancellables.removeAll()
    }
}
