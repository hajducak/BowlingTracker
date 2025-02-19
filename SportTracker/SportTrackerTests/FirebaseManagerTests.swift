import XCTest
import Combine
@testable import SportTracker

class FirebaseManagerTests: XCTestCase {
    var firebaseManager: MockFirebaseManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        firebaseManager = MockFirebaseManager()
    }

    override func tearDown() {
        cancellables = nil
        firebaseManager = nil
        super.tearDown()
    }

    func test_whenSaveSeries_thenSuccessIsSown() throws {
        let expectation = self.expectation(description: "Series saved successfully")

        let series = Series(name: "Test Series", tag: .training)

        firebaseManager.saveSeries(series)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Saving series failed: \(error.localizedDescription)")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func test_givenError_whenSaveSeries_thenFailureIsSown() throws {
        let expectation = self.expectation(description: "Saving series should fail")
        firebaseManager.shouldFail = true

        let series = Series(name: "Test Series", tag: .training)

        firebaseManager.saveSeries(series)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: {
                XCTFail("Save should have failed")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func test_whenFetchAllSeries_thenSuccessIsSown() throws {
        let expectation = self.expectation(description: "Fetch all series")

        let series1 = Series(name: "Series 1", tag: .training)
        let series2 = Series(name: "Series 2", tag: .tournament)
        
        _ = firebaseManager.saveSeries(series1)
        _ = firebaseManager.saveSeries(series2)

        firebaseManager.fetchAllSeries()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Fetching series failed: \(error.localizedDescription)")
                }
            }, receiveValue: { seriesList in
                XCTAssertEqual(seriesList.count, 2, "Should fetch 2 series")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func test_givenError_whenFetchAllSeries_thenFailureIsSown() throws {
        let expectation = self.expectation(description: "Fetching series should fail")
        firebaseManager.shouldFail = true

        firebaseManager.fetchAllSeries()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Fetching should have failed")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func test_givenSuccess_whenFetchPerformances_thenSuccessIsShown() {
        let expectedPerformances: [SportPerformance] = [
            SportPerformance(id: "1", name: "Firebase Performance 1", location: "Location 1", duration: 10, storageType: StorageType.remote.rawValue)
        ]
        firebaseManager.performancesToReturn = expectedPerformances
        firebaseManager.shouldReturnError = false

        let publisher = firebaseManager.fetchPerformances()

        let expectation = self.expectation(description: "fetchPerformancesSuccess")

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but received failure: \(error)")
                }
            }, receiveValue: { performances in
                XCTAssertEqual(performances.count, expectedPerformances.count, "The number of fetched performances should match the expected count.")
                XCTAssertEqual(performances.first?.name, expectedPerformances.first?.name, "The first performance name should match.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_givenError_whenFetchPerformances_thenFailureIsShown() {
        firebaseManager.shouldReturnError = true

        let publisher = firebaseManager.fetchPerformances()

        let expectation = self.expectation(description: "fetchPerformancesFailure")

        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if case .fetchingError = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected fetchingError, but received a different error: \(error)")
                    }
                case .finished:
                    XCTFail("Expected failure, but received success.")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, but received data.")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_givenSuccess_whenSavePerformance_thenSuccessIsShown() {
        let performance = SportPerformance(id: "1", name: "Test Performance", location: "Test Location", duration: 15, storageType: StorageType.remote.rawValue)

        firebaseManager.shouldReturnError = false

        let publisher = firebaseManager.savePerformance(performance)

        let expectation = self.expectation(description: "savePerformanceSuccess")

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but received failure: \(error)")
                }
            }, receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_givenFailure_whenSavePerformance_thenFailureIsShown() {
        let performance = SportPerformance(id: "1", name: "Test Performance", location: "Test Location", duration: 15, storageType: StorageType.remote.rawValue)

        firebaseManager.shouldReturnError = true

        let publisher = firebaseManager.savePerformance(performance)

        let expectation = self.expectation(description: "savePerformanceFailure")

        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if case .saveError = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected saveError, but received a different error: \(error)")
                    }
                case .finished:
                    XCTFail("Expected failure, but received success.")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, but received success.")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_whenDeletePerformanceById() {
        firebaseManager.shouldReturnError = false

        let publisher = firebaseManager.deletePerformance(with: "1")
        let expectation = self.expectation(description: "deletePerformanceById")

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but received failure: \(error)")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_whenDeleteAllPerformances() {
        firebaseManager.shouldReturnError = false

        let publisher = firebaseManager.deleteAllPerformances()
        let expectation = self.expectation(description: "deleteAllPerformances")

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but received failure: \(error)")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }
}

class MockFirebaseManager: FirebaseManager {
    var shouldReturnError = false
    var performancesToReturn: [SportPerformance] = []
    
    override init() {}

    override func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, AppError> {
        if shouldReturnError {
            return Fail(error: AppError.saveError(NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])))
                .eraseToAnyPublisher()
        } else {
            performancesToReturn.append(performance)
            return Just(()).setFailureType(to: AppError.self).eraseToAnyPublisher()
        }
    }

    override func fetchPerformances() -> AnyPublisher<[SportPerformance], AppError> {
        if shouldReturnError {
            return Fail(error: AppError.fetchingError(NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])))
                .eraseToAnyPublisher()
        } else {
            return Just(performancesToReturn)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }
    }

    override func deleteAllPerformances() -> AnyPublisher<Void, AppError> {
        if shouldReturnError {
            return Fail(error: AppError.deletingError(NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])))
                .eraseToAnyPublisher()
        } else {
            performancesToReturn.removeAll()
            return Just(()).setFailureType(to: AppError.self).eraseToAnyPublisher()
        }
    }
    
    override func deletePerformance(with id: String) -> AnyPublisher<Void, AppError> {
        if shouldReturnError {
            return Fail(error: AppError.deletingError(NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])))
                .eraseToAnyPublisher()
        } else {
            performancesToReturn.removeAll { $0.id == id }
            return Just(()).setFailureType(to: AppError.self).eraseToAnyPublisher()
        }
    }
    
    var storedSeries: [Series] = []
    var shouldFail = false

    override func saveSeries(_ series: Series) -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            if self.shouldFail {
                promise(.failure(.saveError(NSError(domain: "TestError", code: -1, userInfo: nil))))
            } else {
                var newSeries = series
                newSeries.id = UUID().uuidString
                self.storedSeries.append(newSeries)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    override func fetchAllSeries() -> AnyPublisher<[Series], AppError> {
        return Future<[Series], AppError> { promise in
            if self.shouldFail {
                promise(.failure(.fetchingError(NSError(domain: "TestError", code: -1, userInfo: nil))))
            } else {
                promise(.success(self.storedSeries))
            }
        }
        .eraseToAnyPublisher()
    }
}
