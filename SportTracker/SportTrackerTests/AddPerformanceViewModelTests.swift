import XCTest
import SwiftData
import Combine
@testable import SportTracker

class AddPerformanceViewModelTests: XCTestCase {
    var viewModel: AddPerformanceViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockStorageManager: MockStorageManager!
    var firebaseManager: MockFirebaseManager!
    
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
               firebaseManager = MockFirebaseManager()
               viewModel = AddPerformanceViewModel(storageManager: mockStorageManager, firebaseManager: firebaseManager)
               expectation.fulfill()
           } catch {
               XCTFail("Error initializing model container: \(error)")
           }
       }
       waitForExpectations(timeout: 5, handler: nil)
   }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockStorageManager = nil
        firebaseManager = nil
        super.tearDown()
    }

    @MainActor func testSavePerformance() {
        viewModel.name = "Performance 1"
        viewModel.location = "Location 1"
        viewModel.duration = "15"
        viewModel.storageType = .local
        viewModel.savePerformance()

        XCTAssertEqual(mockStorageManager.performances.count, 1, "One performance should be saved in the mock storage.")
        XCTAssertEqual(mockStorageManager.performances.first?.name, "Performance 1", "The saved performance name should match.")
        XCTAssertEqual(mockStorageManager.performances.first?.location, "Location 1", "The saved performance location should match.")
        XCTAssertEqual(mockStorageManager.performances.first?.duration, 15, "The saved performance duration should match.")
        XCTAssertEqual(mockStorageManager.performances.first?.storageType, StorageType.local.rawValue, "The saved performance storage type should match.")
    }

    @MainActor func testSavePerformanceWithFirebaseFailure() {
        firebaseManager.shouldReturnError = true
        viewModel.name = "Performance 1"
        viewModel.location = "Location 1"
        viewModel.duration = "15"
        viewModel.storageType = .local
        viewModel.savePerformance()

        XCTAssertEqual(mockStorageManager.performances.count, 1, "One performance should be saved in the mock storage.")
    }
}
