import Foundation
import Combine

class PerformanceListViewModel: ObservableObject {
    @Published var performances: [SportPerformance] = []
    @Published var isLoading: Bool = true
    @Published var toast: Toast? = nil
    
    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    func isEmpty(selectedFilter: StorageType?) -> Bool {
        switch selectedFilter {
        case .local:
            return performances.filter({ $0.storageType == StorageType.local.rawValue }).isEmpty && !isLoading
        case .remote:
            return performances.filter({ $0.storageType == StorageType.remote.rawValue }).isEmpty && !isLoading
        case .none:
            return performances.isEmpty && !isLoading
        }
    }

    @MainActor func fetchPerformances(filter: StorageType?) {
        isLoading = true
        switch filter {
        case .local:
            storageManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case .failure(let error) = completion {
                        toast = .init(type: .error(error), message: "Error fetching local performances:")
                    }
                }, receiveValue: { [weak self] performances in
                    guard let self else { return }
                    self.performances = performances.filter { $0.storageType == StorageType.local.rawValue }
                })
                .store(in: &cancellables)
        case .remote:
            firebaseManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case .failure(let error) = completion {
                        toast = .init(type: .error(error), message: "Error fetching remote performances:")
                    }
                }, receiveValue: { [weak self] performances in
                    guard let self else { return }
                    self.performances = performances.filter { $0.storageType == StorageType.remote.rawValue }
                })
                .store(in: &cancellables)
        case .none:
            storageManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case .failure(let error) = completion {
                        toast = .init(type: .error(error), message: "Error fetching local performances:")
                    }
                }, receiveValue: { [weak self] performances in
                    guard let self else { return }
                    self.performances = performances
                })
                .store(in: &cancellables)
            firebaseManager.fetchPerformances()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case .failure(let error) = completion {
                        toast = .init(type: .error(error), message: "Error fetching remote performances:")
                    }
                }, receiveValue: { [weak self] performances in
                    guard let self else { return }
                    self.performances.append(contentsOf: performances)
                })
                .store(in: &cancellables)
        }
    }

    @MainActor func deletePerformance(_ performance: SportPerformance) {
        if performance.storageType == StorageType.local.rawValue {
            storageManager.deletePerformance(with: performance.id)
            if let index = performances.firstIndex(where: { $0.id == performance.id }) {
                performances.remove(at: index)
            }
        } else {
            firebaseManager.deletePerformance(with: performance.id)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        toast = .init(type: .error(error), message: "Error deleting remote performance:")
                    }
                }, receiveValue: { [weak self] in
                    guard let self else { return }
                    if let index = performances.firstIndex(where: { $0.id == performance.id }) {
                        performances.remove(at: index)
                    }
                })
                .store(in: &cancellables)
        }
    }

    @MainActor func deleteAllPerformances() {
        storageManager.deleteAllPerformances()
        firebaseManager.deleteAllPerformances()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = .init(type: .error(error), message: "Error deleting all remote performances:")
                }
            }, receiveValue: { [weak self] _ in
                guard let self else { return }
                performances.removeAll()
            })
            .store(in: &cancellables)
    }
}
