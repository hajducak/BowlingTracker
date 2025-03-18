import XCTest
import Combine
import FirebaseFirestore
@testable import BowlingTracker

class SeriesViewModelTests: XCTestCase {
    var sut: SeriesViewModel!
    var mockFirebaseService: MockSeriesFirebaseService!
    var mockSeriesViewModelFactory: MockSeriesDetailViewModelFactory!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFirebaseService = MockSeriesFirebaseService(mockFirestore: MockFirestore(), collectionName: CollectionNames.series)
        mockSeriesViewModelFactory = MockSeriesDetailViewModelFactory()
        sut = SeriesViewModel(seriesViewModelFactory: mockSeriesViewModelFactory, firebaseService: mockFirebaseService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockFirebaseService = nil
        mockSeriesViewModelFactory = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.state, .loading)
        XCTAssertNil(sut.toast)
        XCTAssertEqual(sut.newSeriesName, "")
        XCTAssertEqual(sut.newSeriesDescription, "")
        XCTAssertEqual(sut.newSeriesOilPatternName, "")
        XCTAssertEqual(sut.newSeriesOilPatternURL, "")
        XCTAssertEqual(sut.newSeriesHouseName, "")
        XCTAssertEqual(sut.newSeriesSelectedType, .league)
        XCTAssertNil(sut.selectedFilter)
    }
    
    // MARK: - Fetch Series Tests
    
    func testFetchSeries_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Series should be fetched")
        let mockSeries = [
            Series(name: "Test Series 1", tag: .league),
            Series(name: "Test Series 2", tag: .training)
        ]
        
        // When
        mockFirebaseService.mockDocuments = mockSeries.map { series in
            MockDocumentSnapshot(id: series.id, data: try! Firestore.Encoder().encode(series))
        }
        
        sut.$state
            .dropFirst()
            .sink { state in
                if case .content(let viewModels) = state {
                    XCTAssertEqual(viewModels.count, 2)
                    XCTAssertEqual(viewModels[0].series.name, "Test Series 1")
                    XCTAssertEqual(viewModels[1].series.name, "Test Series 2")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchSeries_Empty() {
        // Given
        let expectation = XCTestExpectation(description: "State should be empty")
        
        // When
        mockFirebaseService.mockDocuments = []
        
        sut.$state
            .dropFirst()
            .sink { state in
                if case .empty = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchSeries_Failure() {
        // Given
        let expectation = XCTestExpectation(description: "Should show error toast")
        
        // When
        mockFirebaseService.shouldSucceed = false
        mockFirebaseService.error = .customError("Failed to fetch")
        
        sut.$toast
            .dropFirst()
            .sink { toast in
                if case .error(let error) = toast?.type {
                    XCTAssertEqual(error, .customError("Failed to fetch"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Add Series Tests
    
    func testAddSeries_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Series should be added")
        sut.newSeriesName = "New Series"
        sut.newSeriesDescription = "Description"
        sut.newSeriesOilPatternName = "Pattern"
        sut.newSeriesOilPatternURL = "URL"
        sut.newSeriesHouseName = "House"
        sut.newSeriesSelectedType = .league
        sut.newSeriesSelectedDate = Date()
        
        // When
        mockFirebaseService.shouldSucceed = true
        
        sut.$toast
            .dropFirst()
            .sink { toast in
                if case .success(let message) = toast?.type {
                    XCTAssertEqual(message, "Serie saved")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.addSeries()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddSeries_Failure() {
        // Given
        let expectation = XCTestExpectation(description: "Should show error toast")
        sut.newSeriesName = "New Series"
        mockFirebaseService.shouldSucceed = false
        mockFirebaseService.error = .customError("Failed to save")
        
        // When
        sut.$toast
            .dropFirst()
            .sink { toast in
                if case .error(let error) = toast?.type {
                    XCTAssertEqual(error, .customError("Failed to save"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.addSeries()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Delete Series Tests
    
    func testDeleteSeries_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Series should be deleted")
        let series = Series(name: "Test Series", tag: .league)
        mockFirebaseService.shouldSucceed = true
        
        // When
        sut.deleteSeries(series)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteSeries_Failure() {
        // Given
        let expectation = XCTestExpectation(description: "Should show error toast")
        let series = Series(name: "Test Series", tag: .league)
        mockFirebaseService.shouldSucceed = false
        mockFirebaseService.error = .customError("Failed to delete")
        
        // When
        sut.$toast
            .dropFirst()
            .sink { toast in
                if case .error(let error) = toast?.type {
                    XCTAssertEqual(error, .customError("Failed to delete"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.deleteSeries(series)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Filter Tests
    
    func testFilterSeries() {
        // Given
        let expectation = XCTestExpectation(description: "Series should be filtered")
        let mockSeries = [
            Series(name: "League Series", tag: .league),
            Series(name: "Practice Series", tag: .training)
        ]
        mockFirebaseService.mockDocuments = mockSeries.map { series in
            MockDocumentSnapshot(id: series.id, data: try! Firestore.Encoder().encode(series))
        }
        
        // When
        sut.$state
            .dropFirst(2)
            .sink { state in
                if case .content(let viewModels) = state {
                    XCTAssertEqual(viewModels.count, 1)
                    XCTAssertEqual(viewModels[0].series.tag, .league)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.selectedFilter = .league
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Series Detail View Model Factory

class MockSeriesDetailViewModelFactory: SeriesDetailViewModelFactory {
    func viewModel(series: Series) -> SeriesDetailViewModel {
        let mockFirebaseService = MockSeriesFirebaseService(mockFirestore: MockFirestore(), collectionName: CollectionNames.series)
        let mockGameViewModelFactory = MockGameViewModelFactory()
        return SeriesDetailViewModel(firebaseService: mockFirebaseService, gameViewModelFactory: mockGameViewModelFactory, series: series)
    }
}

// MARK: - Mock Game View Model Factory

class MockGameViewModelFactory: GameViewModelFactory {
    func viewModel(game: Game) -> GameViewModel {
        return GameViewModel(game: game)
    }
} 
