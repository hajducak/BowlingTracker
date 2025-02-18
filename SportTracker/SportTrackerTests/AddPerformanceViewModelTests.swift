import XCTest
import SwiftData
import Combine
@testable import SportTracker

class AddPerformanceViewModelTests: XCTestCase {
    var viewModel: AddPerformanceViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockStorageManager: MockStorageManager!
    var mockFirebaseManager: MockFirebaseManager!

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
                mockFirebaseManager = MockFirebaseManager()
                viewModel = AddPerformanceViewModel(storageManager: mockStorageManager, firebaseManager: mockFirebaseManager)
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
        mockFirebaseManager = nil
        super.tearDown()
    }

    @MainActor func test_whenSavePerformance_thenLocalSavedAndShownSuccess() {
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
        XCTAssertEqual(viewModel.toast?.toastMessage, "✅ Performance saved locally!", "Toast message should indicate local save success.")
    }

    @MainActor func test_whenSavePerformance_theRemoteSavedAndShownSuccess() {
        viewModel.name = "Swimming"
        viewModel.location = "Pool"
        viewModel.duration = "45"
        viewModel.storageType = .remote
        let expectation = expectation(description: "Firebase save should succeed")
        viewModel.savePerformance()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after saving.")
            XCTAssertEqual(self.viewModel.toast?.toastMessage, "✅ Performance saved to Firebase!", "Toast message should indicate Firebase success.")
            XCTAssertNotNil(self.viewModel.toast, "Toast should be displayed.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    @MainActor func test_givenFailure_whenSavePerformance_thenFailureRemoteSaveAndShownError() {
        viewModel.name = "Cycling"
        viewModel.location = "Trail"
        viewModel.duration = "50"
        viewModel.storageType = .remote
        mockFirebaseManager.shouldReturnError = true
        let expectation = expectation(description: "Firebase save should fail")

        viewModel.savePerformance()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after failure.")
            XCTAssertTrue(self.viewModel.toast?.toastMessage.contains("⚠️ Error saving to Firebase") ?? false, "Toast message should indicate Firebase failure.")
            XCTAssertNotNil(self.viewModel.toast, "Toast should be displayed.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    @MainActor func test_gicingEmptyField_whenSavePerformance_thenUserErrorShown() {
        viewModel.name = ""
        viewModel.location = ""
        viewModel.duration = ""
        viewModel.savePerformance()

        XCTAssertEqual(viewModel.toast?.toastMessage, "❌ Please fill in all fields correctly.", "Toast message should indicate missing fields.")
        XCTAssertNotNil(viewModel.toast, "Toast should be displayed.")
        XCTAssertFalse(viewModel.isLoading, "Loading should remain false.")
    }

    @MainActor func test_whenSavePerformance_thenLoadingStateIsShown() {
        viewModel.name = "Yoga"
        viewModel.location = "Studio"
        viewModel.duration = "40"
        viewModel.storageType = .remote

        let expectation = expectation(description: "Check loading state")
        viewModel.savePerformance()

        XCTAssertTrue(viewModel.isLoading, "Loading should be true while saving.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after completion.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_givenEmptyFields_whenInit_thenButtonIsDisabled() {
        viewModel.name = ""
        viewModel.location = ""
        viewModel.duration = ""
        
        XCTAssertTrue(viewModel.isDisabled, "Button should be disabled when fields are empty")
    }

    func test_givenNonEmptyFields_whenInit_thenButtonIsEnabled() {
        viewModel.name = "Performance"
        viewModel.location = "Location"
        viewModel.duration = "30"
        
        XCTAssertFalse(viewModel.isDisabled, "Button should be enabled when fields are filled")
    }
}
