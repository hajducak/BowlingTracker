import Foundation
import Combine

enum SeriesDetailContentState {
    case empty
    case content([Game])
    case playing(GameViewModel)
}

final class SeriesDetailViewModel: ObservableObject, Identifiable {
    // MARK: - Published Properties
    @Published var games: [Game] = []
    @Published var state: SeriesDetailContentState = .empty
    @Published var toast: Toast? = nil
    @Published var series: Series
    @Published var gameViewModel: GameViewModel?
    @Published var shouldDismiss: Bool = false
    @Published var isLoadingOverlay: Bool = false
    
    // MARK: - Series Edit Properties
    @Published var newSeriesName: String
    @Published var newSeriesDescription: String
    @Published var newSeriesOilPatternName: String
    @Published var newSeriesOilPatternURL: String
    @Published var newSeriesHouseName: String
    @Published var newSeriesSelectedType: SeriesType
    @Published var newSeriesSelectedDate: Date
    
    // MARK: - View Models
    var basicStatisticsViewModel: BasicStatisticsViewModel?
    var advancedStatisticsViewModel: AdvancedStatisticsViewModel?
    var pinCoverageViewModel: PinCoverageViewModel?
    
    // MARK: - Dependencies
    private let gameViewModelFactory: GameViewModelFactory
    private let userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Publishers
    let seriesSaved = PassthroughSubject<Series, Never>()
    
    init(userService: UserService, gameViewModelFactory: GameViewModelFactory, series: Series) {
        self.userService = userService
        self.gameViewModelFactory = gameViewModelFactory
        self.series = series
        self.games = series.games

        self.newSeriesName = series.name
        self.newSeriesDescription = series.description
        self.newSeriesOilPatternName = series.oilPatternName ?? ""
        self.newSeriesOilPatternURL = series.oilPatternURL ?? ""
        self.newSeriesHouseName = series.house ?? ""
        self.newSeriesSelectedType = series.tag
        self.newSeriesSelectedDate = series.date

        setupContent()
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        setupGameViewModelSubscription()
        setupSeriesSubscription()
    }
    
    private func setupGameViewModelSubscription() {
        $gameViewModel
            .compactMap { $0 }
            .flatMap { $0.gameSaved }
            .sink { [weak self] savedGame in
                self?.saveCurrent(game: savedGame)
            }
            .store(in: &cancellables)
    }
    
    private func setupSeriesSubscription() {
        $series
            .sink { [weak self] series in
                self?.updateStatisticsViewModels(with: series)
            }
            .store(in: &cancellables)
    }
    
    private func updateStatisticsViewModels(with series: Series) {
        if basicStatisticsViewModel == nil {
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
    }

    private func setupContent() {
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
        isLoadingOverlay = true
        
        userService.fetchUserData()
            .flatMap { [weak self] user -> AnyPublisher<Void, AppError> in
                guard let self = self, let userData = user else {
                    return Fail(error: AppError.customError("User not found")).eraseToAnyPublisher()
                }
                let updatedUser = userData.appendGameToSeries(seriesId: self.series.id, game: game)
                return userService.saveUser(updatedUser)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoadingOverlay = false
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                toast = Toast(type: .success("Successfully saved in Database"))
                series.newGame()
                fetchUpdatedSeries()
                setupContent()
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
        series.currentGame = nil
        userService.fetchUserData()
            .flatMap { [weak self] user -> AnyPublisher<Void, AppError> in
                guard let self = self, let userData = user else {
                    return Fail(error: AppError.customError("User not found")).eraseToAnyPublisher()
                }
                let updatedUser = userData.updateSeries(series)
                return userService.saveUser(updatedUser)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoadingOverlay = false
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
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
                updateParameter(&seriesToUpdate)
                
                let updatedUser = userData.updateSeries(seriesToUpdate)
                return userService.saveUser(updatedUser)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoadingOverlay = false
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                toast = Toast(type: .success("Series successfully edited"))
                fetchUpdatedSeries()
                reloadSeries()
            }
            .store(in: &cancellables)
    }
    
    private func updateParameter(_ series: inout Series) {
        if let newDate = self.valueIfModified(self.newSeriesSelectedDate, self.series.date) {
            series.date = newDate
        }
        if let newName = self.valueIfModified(self.newSeriesName, self.series.name) {
            series.name = newName
        }
        if let newDescription = self.valueIfModified(self.newSeriesDescription, self.series.description) {
            series.description = newDescription
        }
        if let newTag = self.valueIfModified(self.newSeriesSelectedType, self.series.tag) {
            series.tag = newTag
        }
        if let newOilPatternName = self.valueIfModified(self.newSeriesOilPatternName, self.series.oilPatternName ?? "") {
            series.oilPatternName = newOilPatternName
        }
        if let newOilPatternURL = self.valueIfModified(self.newSeriesOilPatternURL, self.series.oilPatternURL ?? "") {
            series.oilPatternURL = newOilPatternURL
        }
        if let newHouse = self.valueIfModified(self.newSeriesHouseName, self.series.house ?? "") {
            series.house = newHouse
        }
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
