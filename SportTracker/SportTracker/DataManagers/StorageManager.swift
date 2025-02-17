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
    func clearPerformances() {
        do {
            let descriptor = FetchDescriptor<SportPerformance>()
            let performances = try modelContext.fetch(descriptor)
            for performance in performances {
                modelContext.delete(performance)
            }
            try modelContext.save()
        } catch {
            print("⚠️ Error while clearing performances: \(error.localizedDescription)")
        }
    }
}
