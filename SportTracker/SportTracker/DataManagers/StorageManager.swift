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
    func savePerformance(_ performance: SportPerformance) {
        modelContext.insert(performance)
        do {
            try modelContext.save()
        } catch {
            print("⚠️ Error while save data: \(error.localizedDescription)")
        }
    }

    @MainActor
    func fetchPerformances() -> AnyPublisher<[SportPerformance], Error> {
        let descriptor = FetchDescriptor<SportPerformance>()
        return Future<[SportPerformance], Error> { promise in
            do {
                let performances = try self.modelContext.fetch(descriptor)
                promise(.success(performances))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    @MainActor
    func deleteAllPerformances() {
        do {
            let performances = try modelContext.fetch(FetchDescriptor<SportPerformance>())
            for performance in performances {
                modelContext.delete(performance)
            }
            try modelContext.save()
        } catch {
            print("⚠️ Error while deleting all performances: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deletePerformance(with id: String) {
        do {
            let performances = try modelContext.fetch(FetchDescriptor<SportPerformance>())
            if let performance = performances.first(where: { $0.id == id }) {
                modelContext.delete(performance)
                try modelContext.save()
            }
        } catch {
            print("⚠️ Error while deleting performance by ID: \(error.localizedDescription)")
        }
    }
}
