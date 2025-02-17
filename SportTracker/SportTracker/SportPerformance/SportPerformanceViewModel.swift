import Foundation
import Combine

class SportPerformanceViewModel: ObservableObject {
    @Published var performances: [SportPerformance] = []
    private var storageManager: StorageManager
    private var firebaseManager: FirebaseManager
    
    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    @MainActor func addPerformance(name: String, location: String, duration: Int, storageType: StorageType) {
        let performance = SportPerformance(name: name, location: location, duration: duration, storageType: storageType.rawValue)

        if storageType == .local {
            storageManager.savePerformance(performance)
        } else {
            firebaseManager.savePerformance(performance) { error in
                if let error = error {
                    print("Error saving to Firebase: \(error.localizedDescription)")
                }
            }
        }
    }

    @MainActor func fetchPerformances(filter: StorageType?) {
        if let filter = filter {
            performances = filter == .local ? storageManager.fetchPerformances() : []
            if filter == .remote {
                firebaseManager.fetchPerformances { performances, error in
                    if let performances = performances {
                        self.performances = performances
                    }
                }
            }
        } else {
            performances = storageManager.fetchPerformances()
            firebaseManager.fetchPerformances { performances, error in
                if let performances = performances {
                    self.performances.append(contentsOf: performances)
                }
            }
        }
    }
}
