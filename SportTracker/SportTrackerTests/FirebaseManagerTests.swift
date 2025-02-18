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
                    XCTAssertEqual((error as NSError).code, 1, "The error code should be 1.")
                    expectation.fulfill()
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
                    XCTAssertEqual((error as NSError).code, 1, "The error code should be 1.")
                    expectation.fulfill()
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

    override func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"]))
                .eraseToAnyPublisher()
        } else {
            performancesToReturn.append(performance)
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }

    override func fetchPerformances() -> AnyPublisher<[SportPerformance], Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"]))
                .eraseToAnyPublisher()
        } else {
            return Just(performancesToReturn)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    override func deleteAllPerformances() -> AnyPublisher<Void, Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"]))
                .eraseToAnyPublisher()
        } else {
            performancesToReturn.removeAll()
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }

    override func deletePerformance(with id: String) -> AnyPublisher<Void, Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "MockFirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"]))
                .eraseToAnyPublisher()
        } else {
            performancesToReturn.removeAll { $0.id == id }
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}
