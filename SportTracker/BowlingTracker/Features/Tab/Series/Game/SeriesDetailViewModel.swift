import Foundation
import Combine

enum SeriesDetailContentState {
    case empty
    case content([Game])
    case playing(GameViewModel)
}

class SeriesDetailViewModel: ObservableObject, Identifiable {
    @Published var games: [Game] = []
    @Published var state: SeriesDetailContentState = .empty
    @Published var toast: Toast? = nil
    @Published var series: Series
    @Published var gameViewModel: GameViewModel?
    @Published var shouldDismiss: Bool = false
    @Published var isLoadingOverlay: Bool = false
    var basicStatisticsViewModel: BasicStatisticsViewModel?
    private let gameViewModelFactory: GameViewModelFactory
    private let firebaseService: FirebaseService<Series>
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: for editing the series
    @Published var newSeriesName: String
    @Published var newSeriesDescription: String
    @Published var newSeriesOilPatternName: String
    @Published var newSeriesOilPatternURL: String
    @Published var newSeriesHouseName: String
    @Published var newSeriesSelectedType: SeriesType
    @Published var newSeriesSelectedDate: Date
    
    let seriesSaved = PassthroughSubject<Series, Never>()

    init(firebaseService: FirebaseService<Series>, gameViewModelFactory: GameViewModelFactory, series: Series) {
        self.firebaseService = firebaseService
        self.gameViewModelFactory = gameViewModelFactory
        self.series = series
        self.games = series.games
        self.newSeriesName = series.name
        self.newSeriesDescription = series.description
        self.newSeriesOilPatternName = series.oilPatternName ?? ""
        self.newSeriesOilPatternURL = series.oilPatternURL  ?? ""
        self.newSeriesHouseName = series.house ?? ""
        self.newSeriesSelectedType = series.tag
        self.newSeriesSelectedDate = series.date
        setupContent()

        $gameViewModel
            .compactMap { $0 }
            .flatMap { $0.gameSaved }
            .sink { [weak self] savedGame in
                self?.saveCurrent(game: savedGame)
            }
            .store(in: &cancellables)
        
        $series
            .sink { [weak self] series in
                guard let self else { return }
                if basicStatisticsViewModel == nil  {
                    basicStatisticsViewModel = .init(series: [series])
                } else {
                    basicStatisticsViewModel?.series = [series]
                }
            }.store(in: &cancellables)
    }

    func setupContent() {
        if series.isCurrentGameActive() {
            guard let currentGame = series.currentGame else {
                state = series.games.isEmpty ? .empty : .content(games)
                return
            }
            let viewModel = gameViewModelFactory.viewModel(game: currentGame)
            self.gameViewModel = viewModel
            state = .playing(viewModel)
        } else {
            state = series.games.isEmpty ? .empty : .content(games)
        }
    }

    func getCurrentGameScore() -> Int {
        series.getCurrentGameScore() ?? 0
    }
    
    /// Locally saves the current game
    private func saveCurrent(game: Game) {
        saveGameIntoSeries(game: game)
    }
    
    /// Creates a new current game locally
    func newGame() {
        series.newGame()
        setupContent()
    }

    /// Saves the game to Firebase and updates the local series data
    func saveGameIntoSeries(game: Game) {
        isLoadingOverlay = true
        firebaseService.saveGameToSeries(seriesID: series.id, game: game)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                toast = Toast(type: .success("Successfully saved in Database"))
                newGame()
                fetchUpdatedSeries()
            }
            .store(in: &cancellables)
    }
    
    /// Fetches the updated series from Firebase
    private func fetchUpdatedSeries() {
        firebaseService.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] allSeries in
                guard let self, let updatedSeries = allSeries.first(where: { $0.id == self.series.id }) else { return }
                series = updatedSeries
                isLoadingOverlay = false
            }
            .store(in: &cancellables)
    }
    
    /// Saves the entire series and ensures `BowlingSeriesViewModel` updates the UI
    func saveSeries() {
        guard !series.games.isEmpty else {
            toast = Toast(type: .error(.customError("No games in series to save")))
            return
        }
        save()
    }
    
    func save() {
        series.currentGame = nil
        firebaseService.save(series, withID: series.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                toast = Toast(type: .success("Series successfully saved"))
                reloadStatistics()
                seriesSaved.send(self.series)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.shouldDismiss = true
                }
            }
            .store(in: &cancellables)
    }

    func updateSeries() {
        isLoadingOverlay = true
        firebaseService.updateSeriesParameters(
            seriesID: series.id,
            date: newSeriesSelectedDate,
            name: newSeriesName,
            description: newSeriesDescription,
            tag: newSeriesSelectedType,
            oilPatternName: newSeriesOilPatternName,
            oilPatternURL: newSeriesOilPatternURL,
            house: newSeriesHouseName
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                toast = Toast(type: .error(error))
                isLoadingOverlay = false
            }
        } receiveValue: { [weak self] _ in
            guard let self else { return }
            toast = Toast(type: .success("Series successfully edited"))
            fetchUpdatedSeries()
            reloadSeries()
        }
        .store(in: &cancellables)
    }
    
    private func reloadStatistics() {
        NotificationCenter.default.post(name: .seriesDidSave, object: nil)
    }
    
    private func reloadSeries() {
        NotificationCenter.default.post(name: .seriesDidEdit, object: nil)
    }
    
    deinit {
        cancellables.removeAll()
    }
}
