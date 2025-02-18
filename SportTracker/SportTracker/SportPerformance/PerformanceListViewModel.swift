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
        var publishers: [AnyPublisher<[SportPerformance], AppError>] = []
        var encounteredErrors: [AppError] = []

        func handleError(_ error: AppError) {
            encounteredErrors.append(error)
        }

        switch filter {
        case .local:
            let localPublisher = storageManager.fetchPerformances()
                .map { $0.filter { $0.storageType == StorageType.local.rawValue } }
                .catch { error -> AnyPublisher<[SportPerformance], AppError> in
                    handleError(error)
                    return Just([])
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            publishers.append(localPublisher)
        case .remote:
            let remotePublisher = firebaseManager.fetchPerformances()
                .map { $0.filter { $0.storageType == StorageType.remote.rawValue } }
                .catch { error -> AnyPublisher<[SportPerformance], AppError> in
                    handleError(error)
                    return Just([])
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            publishers.append(remotePublisher)
        case .none:
            let localPublisher = storageManager.fetchPerformances()
                .catch { error -> AnyPublisher<[SportPerformance], AppError> in
                    handleError(error)
                    return Just([])
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            let remotePublisher = firebaseManager.fetchPerformances()
                .catch { error -> AnyPublisher<[SportPerformance], AppError> in
                    handleError(error)
                    return Just([])
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()
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
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] allPerformances in
                guard let self = self else { return }
                let mergedPerformances = allPerformances.flatMap { $0 }
                self.state = mergedPerformances.isEmpty ? .empty : .content(mergedPerformances)
            }
            .store(in: &cancellables)
    }

    @MainActor func deletePerformance(_ performance: SportPerformance) {
        if performance.storageType == StorageType.local.rawValue {
            storageManager.deletePerformance(with: performance.id)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        self.toast = Toast(type: .error(error))
                    }
                }, receiveValue: { })
                .store(in: &cancellables)
        } else {
            firebaseManager.deletePerformance(with: performance.id)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        self.toast = Toast(type: .error(error))
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
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            }, receiveValue: { [weak self] in
                guard let self else { return }
                self.state = .empty
            })
            .store(in: &cancellables)
        
        firebaseManager.deleteAllPerformances()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.toast = Toast(type: .error(error))
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
}
