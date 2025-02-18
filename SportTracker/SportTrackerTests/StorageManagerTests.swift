import SwiftData
import XCTest
import Combine
@testable import SportTracker

class StorageManagerTests: XCTestCase {
    var mockStorageManager: MockStorageManager!
    var cancellables: Set<AnyCancellable>!

    func makeInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: SportPerformance.self, configurations: config)
    }

    override func setUp() {
        super.setUp()
        cancellables = []

        let expectation = self.expectation(description: "Waiting for setup to complete")
        Task {
            do {
                mockStorageManager = await MockStorageManager(modelContainer: try makeInMemoryContainer())
                expectation.fulfill()
            } catch {
                XCTFail("Error initializing model container: \(error)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    override func tearDown() {
        cancellables = nil
        mockStorageManager = nil
        super.tearDown()
    }

    @MainActor func test_whenSavePerformance_thenPerformancesAreSet() {
        let performance = SportPerformance(id: "1", name: "Test Performance", location: "Test Location", duration: 15, storageType: StorageType.local.rawValue)

        let publisher = mockStorageManager.savePerformance(performance)
        let expectation = self.expectation(description: "Saving performance")

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but received failure: \(error)")
                }
            }, receiveValue: { _ in
                XCTAssertEqual(self.mockStorageManager.performances.count, 1, "One performance should be saved in the mock storage.")
                XCTAssertEqual(self.mockStorageManager.performances.first?.name, "Test Performance", "The saved performance name should match.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    @MainActor func test_whenFetchPerformances_thenReceivedAllData() {
        let performance1 = SportPerformance(id: "1", name: "Performance 1", location: "Location 1", duration: 10, storageType: StorageType.local.rawValue)
        let performance2 = SportPerformance(id: "2", name: "Performance 2", location: "Location 2", duration: 20, storageType: StorageType.remote.rawValue)

        mockStorageManager.savePerformance(performance1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        mockStorageManager.savePerformance(performance2)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        let publisher = mockStorageManager.fetchPerformances()
        let expectation = self.expectation(description: "Fetching performances")

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but received failure: \(error)")
                }
            }, receiveValue: { performances in
                XCTAssertEqual(performances.count, 2, "The number of performances should be 2.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    @MainActor func test_whenDeletePerformanceById_thenPerformanceIsRemoved() {
        let performance1 = SportPerformance(id: "1", name: "Performance 1", location: "Location 1", duration: 10, storageType: StorageType.local.rawValue)
        let performance2 = SportPerformance(id: "2", name: "Performance 2", location: "Location 2", duration: 20, storageType: StorageType.remote.rawValue)

        mockStorageManager.savePerformance(performance1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        mockStorageManager.savePerformance(performance2)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        mockStorageManager.deletePerformance(with: "1")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(mockStorageManager.performances.count, 1, "Only one performance should remain.")
        XCTAssertEqual(mockStorageManager.performances.first?.id, "2", "Remaining performance should have ID 2.")
    }

    @MainActor func test_whenDeleteAllPerformances_thenPerformancesAreRemoved() {
        let performance = SportPerformance(id: "1", name: "Performance", location: "Location", duration: 15, storageType: StorageType.local.rawValue)

        mockStorageManager.savePerformance(performance)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        mockStorageManager.deleteAllPerformances()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(mockStorageManager.performances.count, 0, "All performances should be deleted.")
    }
}

final class MockStorageManager: StorageManager {
    var performances: [SportPerformance] = []

    override init(modelContainer: ModelContainer) {
        super.init(modelContainer: modelContainer)
    }

    override func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, AppError> {
        performances.append(performance)
        return Just(())
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    override func fetchPerformances() -> AnyPublisher<[SportPerformance], AppError> {
        return Just(performances)
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    override func deleteAllPerformances() -> AnyPublisher<Void, AppError> {
        performances.removeAll()
        return Just(())
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    override func deletePerformance(with id: String) -> AnyPublisher<Void, AppError> {
        performances.removeAll { $0.id == id }
        return Just(())
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
}
