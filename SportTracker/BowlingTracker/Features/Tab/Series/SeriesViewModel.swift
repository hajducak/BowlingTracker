import Foundation
import Combine
import FirebaseAuth

enum SeriesContentState: Equatable {
    static func == (lhs: SeriesContentState, rhs: SeriesContentState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
    
    case loading
    case empty
    case content([SeriesDetailViewModel])
}

class SeriesViewModel: ObservableObject {
    @Published var state: SeriesContentState = .loading
    @Published var toast: Toast? = nil
    @Published var newSeriesName = ""
    @Published var newSeriesDescription = ""
    @Published var newSeriesOilPatternName = ""
    @Published var newSeriesOilPatternURL = ""
    @Published var newSeriesHouseName = ""
    @Published var newSeriesSelectedType: SeriesType = .league
    @Published var newSeriesSelectedDate = Date()
    @Published var selectedFilter: SeriesType?
    var seriesDidEdit: Bool = false
    
    let seriesViewModelFactory: SeriesDetailViewModelFactory
    let userService: UserService
    
    var userData: User? = nil
    
    private var cancellables: Set<AnyCancellable> = []

    private var allSeries: [SeriesDetailViewModel] = []
    
    init(
        seriesViewModelFactory: SeriesDetailViewModelFactory,
        userService: UserService
    ) {
        self.seriesViewModelFactory = seriesViewModelFactory
        self.userService = userService
        setupSeries()
        setupFilteringPublisher()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .seriesDidEdit, object: nil)
    }

    /// save flag from seriesDidEdit
    @objc private func reload() {
        seriesDidEdit = true
    }
    
    /// Will fire up when appears and did get notification .seriesDidEdit from SeriesDetialVieModel
    func reloadSeries() {
        guard seriesDidEdit else { return }
        seriesDidEdit = false
        setupSeries()
    }
    
    func refresh() {
        setupSeries(isLoading: false)
    }
 
    private func setupSeries(isLoading: Bool = true) {
        if isLoading { state = .loading }
        userService.fetchUserData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] user in
                guard let self = self, let userData = user else {
                    self?.state = .empty
                    return
                }
                self.userData = userData
                let seriesViewModels = userData.series
                    .sorted(by: { $0.date > $1.date })
                    .compactMap { series in
                        let viewModel = self.seriesViewModelFactory.viewModel(series: series)
                        self.observeSeriesSaved(viewModel)
                        return viewModel
                    }
                
                allSeries = seriesViewModels
                selectedFilter = nil
                state = seriesViewModels.isEmpty ? .empty : .content(seriesViewModels)
            }.store(in: &cancellables)
    }

    private func setupFilteringPublisher() {
        $selectedFilter
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.state != .loading
            }
            .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilter()
            }
            .store(in: &cancellables)
    }

    private func applyFilter() {
        switch state {
        case .loading: return
        default:
           let filteredSeries = selectedFilter == nil ?
               allSeries : allSeries.filter { $0.series.tag == selectedFilter }
           self.state = filteredSeries.isEmpty ? .empty : .content(filteredSeries)
       }
    }
    
    private func observeSeriesSaved(_ seriesViewModel: SeriesDetailViewModel) {
        seriesViewModel.seriesSaved
            .sink { [weak self] _ in
                self?.setupSeries()
            }
            .store(in: &cancellables)
    }

    func addSeries() {
        guard let user = userData else { return }
        
        let newSeries = Series(
            date: newSeriesSelectedDate,
            name: newSeriesName,
            description: newSeriesDescription,
            oilPatternName: newSeriesOilPatternName,
            oilPatternURL: newSeriesOilPatternURL,
            house: newSeriesHouseName,
            tag: newSeriesSelectedType
        )
        
        var updatedUser = user
        updatedUser.series.append(newSeries)
        
        userService.saveUser(updatedUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                self?.resetToDefault()
                self?.setupSeries()
            }
            .store(in: &cancellables)
    }

    private func resetToDefault() {
        newSeriesName = ""
        newSeriesDescription = ""
        newSeriesOilPatternName = ""
        newSeriesOilPatternURL = ""
        newSeriesHouseName = ""
        newSeriesSelectedType = .league
        newSeriesSelectedDate = Date()
    }

    func save(series: Series) {
        guard let user = userData else { return }
        
        var updatedUser = user
        if let index = updatedUser.series.firstIndex(where: { $0.id == series.id }) {
            updatedUser.series[index] = series
        } else {
            updatedUser.series.append(series)
        }
        
        userService.saveUser(updatedUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                self?.toast = Toast(type: .success("Series saved"))
                self?.setupSeries()
            }
            .store(in: &cancellables)
    }
    
    func deleteSeries(_ series: Series) {
        guard let user = userData else { return }
        
        var updatedUser = user
        updatedUser.series.removeAll { $0.id == series.id }
        
        userService.saveUser(updatedUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                self?.setupSeries()
            }
            .store(in: &cancellables)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .seriesDidEdit, object: nil)
        cancellables.removeAll()
    }
}
