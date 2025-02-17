import Foundation
import Combine

class AddPerformanceViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var location: String = ""
    @Published var duration: String = ""
    @Published var storageType: StorageType = .local
    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager
    }

    @MainActor func savePerformance() {
        guard let durationInt = Int(duration), !name.isEmpty, !location.isEmpty else {
            showToast(message: "⚠️ Please fill in all fields correctly.")
            return
        }
        
        let performance = SportPerformance(name: name, location: location, duration: durationInt, storageType: storageType.rawValue)
        
        isLoading = true

        if storageType == .local {
            storageManager.savePerformance(performance)
            isLoading = false
            showToast(message: "✅ Performance saved locally!")
        } else {
            firebaseManager.savePerformance(performance)
                .sink(receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        switch completion {
                        case .finished:
                            self?.showToast(message: "✅ Performance saved to Firebase!")
                        case .failure(let error):
                            self?.showToast(message: "⚠️ Error saving to Firebase: \(error.localizedDescription)")
                        }
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }

    private func showToast(message: String) {
        toastMessage = message
        showToast = true
    }
}
