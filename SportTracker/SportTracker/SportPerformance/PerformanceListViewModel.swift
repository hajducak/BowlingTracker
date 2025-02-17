import Foundation
import Combine

class PerformanceListViewModel: ObservableObject {
    @Published var performances: [SportPerformance] = []
    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    @MainActor func fetchPerformances(filter: StorageType?) {
        if let filter = filter {
            switch filter {
            case .local:
                storageManager.fetchPerformances()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("⚠️ Error fetching local performances: \(error)")
                        }
                    }, receiveValue: { [weak self] performances in
                        self?.performances = performances.filter { $0.storageType == StorageType.local.rawValue }
                    })
                    .store(in: &cancellables)
                
            case .remote:
                firebaseManager.fetchPerformances()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("⚠️ Error fetching remote performances: \(error)")
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
                    if case .failure(let error) = completion {
                        print("⚠️ Error fetching local performances: \(error)")
                    }
                }, receiveValue: { [weak self] performances in
                    self?.performances = performances
                })
                .store(in: &cancellables)

            firebaseManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("⚠️ Error fetching remote performances: \(error)")
                    }
                }, receiveValue: { [weak self] performances in
                    self?.performances.append(contentsOf: performances)
                })
                .store(in: &cancellables)
        }
    }
}
