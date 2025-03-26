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
    var advancedStatisticsViewModel: AdvancedStatisticsViewModel?
    var pinCoverageViewModel: PinCoverageViewModel?
    private let gameViewModelFactory: GameViewModelFactory
    private let userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var newSeriesName: String
    @Published var newSeriesDescription: String
    @Published var newSeriesOilPatternName: String
    @Published var newSeriesOilPatternURL: String
    @Published var newSeriesHouseName: String
    @Published var newSeriesSelectedType: SeriesType
    @Published var newSeriesSelectedDate: Date
    
    let seriesSaved = PassthroughSubject<Series, Never>()

    init(userService: UserService, gameViewModelFactory: GameViewModelFactory, series: Series) {
        self.userService = userService
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
                if advancedStatisticsViewModel == nil {
                    advancedStatisticsViewModel = .init(series: [series])
                } else {
                    advancedStatisticsViewModel?.series = [series]
                }
                if pinCoverageViewModel == nil {
                    pinCoverageViewModel = .init(series: [series])
                } else {
                    pinCoverageViewModel?.series = [series]
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
        
        userService.fetchUserData()
            .flatMap { [weak self] user -> AnyPublisher<Void, AppError> in
                guard let self = self, let userData = user else {
                    return Fail(error: AppError.customError("User not found")).eraseToAnyPublisher()
                }
                let updatedUser = userData.appendGameToSeries(seriesId: self.series.id, game: game)
                return self.userService.saveUser(updatedUser)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingOverlay = false
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.toast = Toast(type: .success("Successfully saved in Database"))
                self.newGame()
                self.fetchUpdatedSeries()
            }
            .store(in: &cancellables)
    }
    
    /// Fetches the updated series from Firebase
    private func fetchUpdatedSeries() {
        userService.fetchUserData()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] user in
                guard let self, let userData = user, let updatedSeries = userData.series.first(where: { $0.id == self.series.id }) else { return }
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
        userService.fetchUserData()
            .flatMap { [weak self] user -> AnyPublisher<Void, AppError> in
                guard let self = self, let userData = user else {
                    return Fail(error: AppError.customError("User not found")).eraseToAnyPublisher()
                }
                let updatedUser = userData.updateSeries(series)
                return self.userService.saveUser(updatedUser)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingOverlay = false
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
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
        
        userService.fetchUserData()
            .flatMap { [weak self] user -> AnyPublisher<Void, AppError> in
                guard let self = self, 
                      let userData = user,
                      var seriesToUpdate = userData.series.first(where: { $0.id == self.series.id }) else {
                    return Fail(error: AppError.customError("Series not found")).eraseToAnyPublisher()
                }
                if let newDate = self.valueIfModified(self.newSeriesSelectedDate, self.series.date) {
                    seriesToUpdate.date = newDate
                }
                if let newName = self.valueIfModified(self.newSeriesName, self.series.name) {
                    seriesToUpdate.name = newName
                }
                if let newDescription = self.valueIfModified(self.newSeriesDescription, self.series.description) {
                    seriesToUpdate.description = newDescription
                }
                if let newTag = self.valueIfModified(self.newSeriesSelectedType, self.series.tag) {
                    seriesToUpdate.tag = newTag
                }
                if let newOilPatternName = self.valueIfModified(self.newSeriesOilPatternName, self.series.oilPatternName ?? "") {
                    seriesToUpdate.oilPatternName = newOilPatternName
                }
                if let newOilPatternURL = self.valueIfModified(self.newSeriesOilPatternURL, self.series.oilPatternURL ?? "") {
                    seriesToUpdate.oilPatternURL = newOilPatternURL
                }
                if let newHouse = self.valueIfModified(self.newSeriesHouseName, self.series.house ?? "") {
                    seriesToUpdate.house = newHouse
                }
                
                let updatedUser = userData.updateSeries(seriesToUpdate)
                return self.userService.saveUser(updatedUser)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingOverlay = false
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.toast = Toast(type: .success("Series successfully edited"))
                self.fetchUpdatedSeries()
                self.reloadSeries()
            }
            .store(in: &cancellables)
    }
    
    private func valueIfModified<T: Equatable>(_ newValue: T, _ oldValue: T) -> T? {
        return newValue == oldValue ? nil : newValue
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
