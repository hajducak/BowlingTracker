import XCTest
import Combine
import FirebaseFirestore
@testable import BowlingTracker

class StatisticsViewModelTests: XCTestCase {
    var sut: StatisticsViewModel!
    var mockFirebaseService: MockSeriesFirebaseService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFirebaseService = MockSeriesFirebaseService(mockFirestore: MockFirestore(), collectionName: CollectionNames.series)
        sut = StatisticsViewModel(firebaseService: mockFirebaseService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockFirebaseService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.totalGames, 0)
        XCTAssertNil(sut.basicStatisticsViewModel)
        XCTAssertNil(sut.selectedFilter)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.toast)
    }
    
    // MARK: - Fetch Series Tests
    
    func testFetchSeries_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Series should be fetched")
        let mockSeries = [
            Series(name: "Test Series 1", tag: .league),
            Series(name: "Test Series 2", tag: .practise)
        ]
        
        // When
        mockFirebaseService.mockDocuments = mockSeries.map { series in
            MockDocumentSnapshot(id: series.id, data: try! Firestore.Encoder().encode(series))
        }
        
        sut.$isLoading
            .dropFirst(2)
            .sink { isLoading in
                XCTAssertFalse(isLoading)
                XCTAssertEqual(self.sut.totalGames, 0) // Since mock series have no games
                expectation.fulfill()
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
    
    // MARK: - Filter Tests
    
    func testFilterSeries() {
        // Given
        let expectation = XCTestExpectation(description: "Series should be filtered")
        let mockSeries = [
            Series(name: "League Series", tag: .league),
            Series(name: "Practice Series", tag: .practise)
        ]
        mockFirebaseService.mockDocuments = mockSeries.map { series in
            MockDocumentSnapshot(id: series.id, data: try! Firestore.Encoder().encode(series))
        }
        
        // When
        sut.$totalGames
            .dropFirst(2)
            .sink { totalGames in
                XCTAssertEqual(totalGames, 0) // Since mock series have no games
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.selectedFilter = .league
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Tests
    
    func testSeriesDidSaveNotification() {
        // Given
        let expectation = XCTestExpectation(description: "Should reload data on notification")
        
        // When
        sut.$isLoading
            .dropFirst(2)
            .sink { isLoading in
                XCTAssertFalse(isLoading)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.post(name: .seriesDidSave, object: nil)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
} 
