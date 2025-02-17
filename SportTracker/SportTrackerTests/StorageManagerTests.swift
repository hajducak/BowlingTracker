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

    @MainActor func testSavePerformance() {
        let performance = SportPerformance(id: "1", name: "Test Performance", location: "Test Location", duration: 15, storageType: StorageType.local.rawValue)

        mockStorageManager.savePerformance(performance)

        XCTAssertEqual(mockStorageManager.performances.count, 1, "One performance should be saved in the mock storage.")
        XCTAssertEqual(mockStorageManager.performances.first?.name, "Test Performance", "The saved performance name should match.")
        XCTAssertEqual(mockStorageManager.performances.first?.location, "Test Location", "The saved performance location should match.")
        XCTAssertEqual(mockStorageManager.performances.first?.duration, 15, "The saved performance duration should match.")
        XCTAssertEqual(mockStorageManager.performances.first?.storageType, StorageType.local.rawValue, "The saved performance storage type should match.")
    }

    @MainActor func testFetchPerformances() {
        let performance1 = SportPerformance(id: "1", name: "Performance 1", location: "Location 1", duration: 10, storageType: StorageType.local.rawValue)
        let performance2 = SportPerformance(id: "2", name: "Performance 2", location: "Location 2", duration: 20, storageType: StorageType.remote.rawValue)

        mockStorageManager.savePerformance(performance1)
        mockStorageManager.savePerformance(performance2)

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

    @MainActor func testClearPerformances() {
        let performance1 = SportPerformance(id: "1", name: "Performance 1", location: "Location 1", duration: 10, storageType: StorageType.local.rawValue)

        mockStorageManager.savePerformance(performance1)
        mockStorageManager.clearPerformances()

        XCTAssertEqual(mockStorageManager.performances.count, 0, "There should be no performances after clearing.")
    }
}
