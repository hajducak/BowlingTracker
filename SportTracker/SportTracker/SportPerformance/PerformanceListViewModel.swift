import Foundation
import Combine

class PerformanceListViewModel: ObservableObject {
    @Published var performances: [SportPerformance] = []
    @Published var isLoading: Bool = false
    @Published var toastMessage: String? = nil
    @Published var showToast: Bool = false
    
    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    func deletePerformance(_ performance: SportPerformance) {
        // TODO: Implement deleting from source Forebase/SwiftData
        if let index = performances.firstIndex(where: { $0.id == performance.id }) {
            performances.remove(at: index)
        }
    }

    func deleteAllPerformances() {
        // TODO: Implement deleting from source Forebase/SwiftData
        performances.removeAll()
    }

    @MainActor func fetchPerformances(filter: StorageType?) {
        isLoading = true
        
        if let filter = filter {
            switch filter {
            case .local:
                storageManager.fetchPerformances()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        self.isLoading = false
                        if case .failure(let error) = completion {
                            self.toastMessage = "⚠️ Error fetching local performances: \(error.localizedDescription)"
                            self.showToast = true
                        }
                    }, receiveValue: { [weak self] performances in
                        self?.performances = performances.filter { $0.storageType == StorageType.local.rawValue }
                    })
                    .store(in: &cancellables)
            case .remote:
                firebaseManager.fetchPerformances()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        self.isLoading = false
                        if case .failure(let error) = completion {
                            self.toastMessage = "⚠️ Error fetching remote performances: \(error.localizedDescription)"
                            self.showToast = true
                        }
                    }, receiveValue: { [weak self] performances in
                        self?.performances = performances.filter { $0.storageType == StorageType.remote.rawValue }
                    })
                    .store(in: &cancellables)
            }
        } else {
            storageManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.toastMessage = "⚠️ Error fetching local performances: \(error.localizedDescription)"
                        self.showToast = true
                    }
                }, receiveValue: { [weak self] performances in
                    self?.performances = performances
                })
                .store(in: &cancellables)

            firebaseManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.toastMessage = "⚠️ Error fetching remote performances: \(error.localizedDescription)"
                        self.showToast = true
                    }
                }, receiveValue: { [weak self] performances in
                    self?.performances.append(contentsOf: performances)
                })
                .store(in: &cancellables)
        }
    }
}
