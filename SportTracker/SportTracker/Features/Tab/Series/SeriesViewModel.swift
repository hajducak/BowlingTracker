import Foundation
import Combine

enum SeriesContentState {
    case loading
    case empty
    case content([SeriesDetailViewModel])
}

class SeriesViewModel: ObservableObject {
    @Published var state: SeriesContentState = .loading
    @Published var series: [SeriesDetailViewModel] = []
    @Published var toast: Toast? = nil
    @Published var newSeriesName = ""
    @Published var newSeriesDescription = ""
    @Published var newSeriesSelectedType: SeriesType = .league
    @Published var newSeriesSelectedDate = Date()

    let seriesViewModelFactory: SeriesDetailViewModelFactory
    let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(seriesViewModelFactory: SeriesDetailViewModelFactory, firebaseManager: FirebaseManager) {
        self.seriesViewModelFactory = seriesViewModelFactory
        self.firebaseManager = firebaseManager
        setupSeries()
    }
    
    func setupSeries() {
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
                self.state = series.isEmpty ? .empty : .content(seriesViewModels)
            }
            .store(in: &cancellables)
    }
    
    private func observeSeriesSaved(_ seriesViewModel: SeriesDetailViewModel) {
        seriesViewModel.seriesSaved
            .sink { [weak self] _ in
                self?.setupSeries()
            }
            .store(in: &cancellables)
    }

    func addSeries() {
        let newSeries = Series(date: newSeriesSelectedDate, name: newSeriesName, description: newSeriesDescription, tag: newSeriesSelectedType)
        save(series: newSeries)
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
