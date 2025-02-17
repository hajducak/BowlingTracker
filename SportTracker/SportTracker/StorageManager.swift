import SwiftData

class StorageManager {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func savePerformance(_ performance: SportPerformance) {
        modelContext.insert(performance)
        do {
            try modelContext.save()
        } catch {
            print("⚠️ Error while save data: \(error.localizedDescription)")
        }
    }

    func fetchPerformances() -> [SportPerformance] {
        let descriptor = FetchDescriptor<SportPerformance>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
