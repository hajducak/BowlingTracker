import Foundation
import Combine

class AddPerformanceViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var location: String = ""
    @Published var duration: String = ""
    @Published var storageType: StorageType = .local

    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager

    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    @MainActor func savePerformance() {
        guard let durationInt = Int(duration), !name.isEmpty, !location.isEmpty else {
            // Handle error - inform user about missing fields
            print("⚠️ Missing required fields")
            return
        }
        
        let performance = SportPerformance(name: name, location: location, duration: durationInt, storageType: storageType.rawValue)
        
        if storageType == .local {
            storageManager.savePerformance(performance)
        } else {
            firebaseManager.savePerformance(performance)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("⚡️ Performance saved to Firebase successfully")
                    case .failure(let error):
                        print("⚠️ Error saving to Firebase: \(error.localizedDescription)")
                    }
                }, receiveValue: { _ in
                    // Optionally, do something after saving to Firebase
                })
                .store(in: &cancellables)
        }
    }
}
