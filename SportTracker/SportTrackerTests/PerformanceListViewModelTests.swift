import XCTest
import SwiftData
import Combine
@testable import SportTracker

class PerformanceListViewModelTests: XCTestCase {
    var viewModel: PerformanceListViewModel!
    var mockStorageManager: MockStorageManager!
    var mockFirebaseManager: MockFirebaseManager!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        let expectation = self.expectation(description: "Waiting for setup to complete")
        Task {
            do {
                mockStorageManager = await MockStorageManager(modelContainer: try ModelContainer(for: SportPerformance.self))
                mockFirebaseManager = MockFirebaseManager()

                viewModel = PerformanceListViewModel(
                    storageManager: mockStorageManager,
                    firebaseManager: mockFirebaseManager
                )
                expectation.fulfill()
            } catch {
                XCTFail("Error initializing model container: \(error)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    override func tearDown() {
        viewModel = nil
        mockStorageManager = nil
        mockFirebaseManager = nil
        cancellables.removeAll()
        super.tearDown()
    }

    @MainActor func test_whenFetchAllPerformances_thenContentShown() {
        let expectation = expectation(description: "Fetch all performances")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .content(let performances) = state, performances.count == 4 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockStorageManager.performances = [
            SportPerformance(name: "Running", location: "Park", duration: 30, storageType: StorageType.local.rawValue),
            SportPerformance(name: "Cycling", location: "Road", duration: 45, storageType: StorageType.local.rawValue)
        ]
        mockFirebaseManager.performancesToReturn = [
            SportPerformance(name: "Swimming", location: "Pool", duration: 60, storageType: StorageType.remote.rawValue),
            SportPerformance(name: "Tennis", location: "Court", duration: 90, storageType: StorageType.remote.rawValue)
        ]

        viewModel.fetchPerformances(filter: nil)
        waitForExpectations(timeout: 2)
    }

    @MainActor func test_whenFetchLocalPerformances_thenContentIsShownWithLocalData() {
        let expectation = expectation(description: "Fetch local performances")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .content(let performances) = state,
                   performances.count == 1,
                   performances.first?.name == "Running" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockStorageManager.performances = [
            SportPerformance(name: "Running", location: "Park", duration: 30, storageType: StorageType.local.rawValue)
        ]

        viewModel.fetchPerformances(filter: .local)
        waitForExpectations(timeout: 2)
    }

    @MainActor func test_whenFetchRemotePerformances_thenContentIsShownWithRemoteData() {
        let expectation = expectation(description: "Fetch remote performances")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .content(let performances) = state,
                   performances.count == 1,
                   performances.first?.name == "Swimming" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockFirebaseManager.performancesToReturn = [
            SportPerformance(name: "Swimming", location: "Pool", duration: 60, storageType: StorageType.remote.rawValue)
        ]

        viewModel.fetchPerformances(filter: .remote)
        waitForExpectations(timeout: 2)
    }

    @MainActor func test_whenFetchPerformances_thenLoadingIsShown() {
        let expectation = self.expectation(description: "State should be loading before data arrives")
        var stateChanged = false

        viewModel.$state
            .sink { state in
                if case .loading = state, !stateChanged {
                    stateChanged = true
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchPerformances(filter: nil)
        waitForExpectations(timeout: 1)
    }

    @MainActor func test_givenEmptyResponse_whenFetchPerformances_thenEmptyIsShown() {
        let expectation = expectation(description: "State should be empty when no performances exist")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .empty = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockStorageManager.performances = []
        mockFirebaseManager.performancesToReturn = []

        viewModel.fetchPerformances(filter: nil)
        waitForExpectations(timeout: 2)
    }
}
