import Foundation
import Combine

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
    let firebaseService: FirebaseService<Series>
    private var cancellables: Set<AnyCancellable> = []

    private var allSeries: [SeriesDetailViewModel] = []
    
    init(seriesViewModelFactory: SeriesDetailViewModelFactory, firebaseService: FirebaseService<Series>) {
        self.seriesViewModelFactory = seriesViewModelFactory
        self.firebaseService = firebaseService
        setupSeries()
        setupFiltering()
        
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
    
    private func setupSeries() {
        state = .loading
        firebaseService.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] series in
                guard let self else { return }
                let seriesViewModels = series.sorted(by: { $0.date > $1.date }).compactMap { series in
                    let viewModel = self.seriesViewModelFactory.viewModel(series: series)
                    self.observeSeriesSaved(viewModel)
                    return viewModel
                }
                self.allSeries = seriesViewModels
                self.selectedFilter = nil
                self.state = seriesViewModels.isEmpty ? .empty : .content(seriesViewModels)
            }
            .store(in: &cancellables)
    }

    private func setupFiltering() {
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
        let newSeries = Series(
            date: newSeriesSelectedDate,
            name: newSeriesName,
            description: newSeriesDescription,
            oilPatternName: newSeriesOilPatternName,
            oilPatternURL: newSeriesOilPatternURL,
            house: newSeriesHouseName,
            tag: newSeriesSelectedType
        )
        save(series: newSeries)
        resetToDefault()
    }

    private func resetToDefault() {
        newSeriesName = ""
        newSeriesDescription = ""
        newSeriesSelectedType = .league
        newSeriesSelectedDate = Date()
    }

    func save(series: Series) {
        firebaseService.save(series, withID: series.id)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                toast = Toast(type: .success("Serie saved"))
                setupSeries()
            }
            .store(in: &cancellables)
    }
    
    func deleteSeries(_ series: Series) {
        firebaseService.delete(id: series.id)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure(let error):
                    toast = Toast(type: .error(error))
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] _ in
                self?.setupSeries()
            })
            .store(in: &cancellables)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .seriesDidEdit, object: nil)
        cancellables.removeAll()
    }
}
