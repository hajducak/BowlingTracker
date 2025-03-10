import Foundation
import Combine

enum SeriesContentState {
    case loading
    case empty
    case content([SeriesDetailViewModel])
}

class SeriesViewModel: ObservableObject {
    @Published var state: SeriesContentState = .loading
    @Published var toast: Toast? = nil
    @Published var newSeriesName = ""
    @Published var newSeriesDescription = ""
    @Published var newSeriesSelectedType: SeriesType = .league
    @Published var newSeriesSelectedDate = Date()
    @Published var selectedFilter: SeriesType?
    
    let seriesViewModelFactory: SeriesDetailViewModelFactory
    let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    private var allSeries: [SeriesDetailViewModel] = []
    
    init(seriesViewModelFactory: SeriesDetailViewModelFactory, firebaseManager: FirebaseManager) {
        self.seriesViewModelFactory = seriesViewModelFactory
        self.firebaseManager = firebaseManager
        setupSeries()
        setupFiltering()
    }
    
    private func setupSeries() {
        state = .loading
        firebaseManager.fetchAllSeries()
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
                self.state = series.isEmpty ? .empty : .content(seriesViewModels)
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
            allSeries : allSeries.filter { $0.series.tag == selectedFilter }
        self.state = filteredSeries.isEmpty ? .empty : .content(filteredSeries)
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
        firebaseManager.saveSeries(series)
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
        firebaseManager.deleteSeries(id: series.id)
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
}
