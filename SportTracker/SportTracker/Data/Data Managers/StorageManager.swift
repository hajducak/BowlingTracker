import SwiftData
import Foundation
import Combine

@MainActor
public class StorageManager {
    let modelContext: ModelContext

    public init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
    }

    @MainActor
    func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, AppError> {
        modelContext.insert(performance)
        return Future<Void, AppError> { [weak self] promise in
            do {
                try self?.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(.saveError(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    @MainActor
    func fetchPerformances() -> AnyPublisher<[SportPerformance], AppError> {
        let descriptor = FetchDescriptor<SportPerformance>()
        return Future<[SportPerformance], AppError> { promise in
            do {
                let performances = try self.modelContext.fetch(descriptor)
                promise(.success(performances))
            } catch {
                promise(.failure(.fetchingError(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    @MainActor
    func deleteAllPerformances() -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            do {
                let performances = try self.modelContext.fetch(FetchDescriptor<SportPerformance>())
                for performance in performances {
                    self.modelContext.delete(performance)
                }
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(.deletingError(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    @MainActor
    func deletePerformance(with id: String) -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            do {
                let performances = try self.modelContext.fetch(FetchDescriptor<SportPerformance>())
                if let performance = performances.first(where: { $0.id == id }) {
                    self.modelContext.delete(performance)
                    try self.modelContext.save()
                    promise(.success(()))
                } else {
                    promise(.failure(.customError("No Data Found")))
                }
            } catch {
                promise(.failure(.deletingError(error)))
            }
        }
        .eraseToAnyPublisher()
    }
}
