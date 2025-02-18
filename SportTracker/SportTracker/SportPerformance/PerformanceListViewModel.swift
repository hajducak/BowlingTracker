import Foundation
import Combine

enum PerformanceListState {
    case loading
    case empty
    case content([SportPerformance])
}

class PerformanceListViewModel: ObservableObject {
    @Published var state: PerformanceListState = .loading
    @Published var toast: Toast? = nil
    
    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    @MainActor func fetchPerformances(filter: StorageType?) {
        state = .loading
        var publishers: [AnyPublisher<[SportPerformance], Never>] = []
        var encounteredErrors: [Error] = []

        func handleError(_ error: Error) {
            encounteredErrors.append(error)
        }

        switch filter {
        case .local:
            let localPublisher = storageManager.fetchPerformances()
                .map { $0.filter { $0.storageType == StorageType.local.rawValue } }
                .catch { error -> Just<[SportPerformance]> in
                    handleError(error)
                    return Just([])
                }
                .eraseToAnyPublisher()
            publishers.append(localPublisher)
            
        case .remote:
            let remotePublisher = firebaseManager.fetchPerformances()
                .map { $0.filter { $0.storageType == StorageType.remote.rawValue } }
                .catch { error -> Just<[SportPerformance]> in
                    handleError(error)
                    return Just([])
                }
                .eraseToAnyPublisher()
            publishers.append(remotePublisher)
            
        case .none:
            let localPublisher = storageManager.fetchPerformances()
                .catch { error -> Just<[SportPerformance]> in
                    handleError(error)
                    return Just([])
                }
                .eraseToAnyPublisher()
            
            let remotePublisher = firebaseManager.fetchPerformances()
                .catch { error -> Just<[SportPerformance]> in
                    handleError(error)
                    return Just([])
                }
                .eraseToAnyPublisher()
            
            publishers.append(localPublisher)
            publishers.append(remotePublisher)
        }

        guard !publishers.isEmpty else {
            state = .empty
            return
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allPerformances in
                guard let self else { return }
                let mergedPerformances = allPerformances.flatMap { $0 }
                state = mergedPerformances.isEmpty ? .empty : .content(mergedPerformances)
                if let firstError = encounteredErrors.first {
                    toast = .init(type: .error(firstError), message: "Error fetching performances")
                }
            }
            .store(in: &cancellables)
    }

    @MainActor func deletePerformance(_ performance: SportPerformance) {
        if performance.storageType == StorageType.local.rawValue {
            storageManager.deletePerformance(with: performance.id)
        } else {
            firebaseManager.deletePerformance(with: performance.id)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        toast = .init(type: .error(error), message: "Error deleting remote performance:")
                    }
                }, receiveValue: { })
                .store(in: &cancellables)
        }
        
        if case .content(var performances) = state {
            performances.removeAll { $0.id == performance.id }
            state = performances.isEmpty ? .empty : .content(performances)
        }
    }

    @MainActor func deleteAllPerformances() {
        storageManager.deleteAllPerformances()
        firebaseManager.deleteAllPerformances()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = .init(type: .error(error), message: "Error deleting all performances:")
                }
            }, receiveValue: { [weak self] in
                guard let self else { return }
                state = .empty
            })
            .store(in: &cancellables)
    }
}
