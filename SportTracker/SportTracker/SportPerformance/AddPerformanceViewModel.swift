import Foundation
import Combine

class AddPerformanceViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var location: String = ""
    @Published var duration: String = ""
    @Published var storageType: StorageType = .local
    @Published var isLoading: Bool = false
    @Published var toast: Toast?

    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    @MainActor func savePerformance() {
        guard let durationInt = Int(duration), !name.isEmpty, !location.isEmpty else {
            toast = Toast(type: .userError, message: "Please fill in all fields correctly.")
            return
        }
        
        let performance = SportPerformance(
            name: name,
            location: location,
            duration: durationInt,
            storageType: storageType.rawValue
        )
        
        isLoading = true

        if storageType == .local {
            storageManager.savePerformance(performance)
            isLoading = false
            toast = Toast(type: .success, message: "Performance saved locally!")
        } else {
            firebaseManager.savePerformance(performance)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        switch completion {
                        case .finished:
                            self.toast = Toast(type: .success, message: "Performance saved to Firebase!")
                        case .failure(let error):
                            self.toast = Toast(type: .error(error), message: "Error saving to Firebase:")
                        }
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
}
