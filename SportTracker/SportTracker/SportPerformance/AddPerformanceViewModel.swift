import Foundation
import Combine

class AddPerformanceViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var location: String = ""
    @Published var duration: String = ""
    @Published var storageType: StorageType = .local
    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @Published var isDisabled: Bool = true

    private let storageManager: StorageManager
    private let firebaseManager: FirebaseManager
    private var cancellables: Set<AnyCancellable> = []

    init(storageManager: StorageManager, firebaseManager: FirebaseManager) {
        self.storageManager = storageManager
        self.firebaseManager = firebaseManager

        Publishers.CombineLatest3($name, $location, $duration)
            .sink { [weak self] name, location, duration in
                guard let self else { return }
                isDisabled = name.isEmpty || location.isEmpty || duration.isEmpty
            }
            .store(in: &cancellables)
    }

    @MainActor func savePerformance() {
        guard let durationInt = Int(duration), !name.isEmpty, !location.isEmpty else {
            toast = Toast(type: .error(.invalidInput))
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
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        switch completion {
                        case .finished:
                            self.toast = Toast(type: .success("Performance saved locally!"))
                            self.setInputToDefault()
                        case .failure(let error):
                            self.toast = Toast(type: .error(error))
                        }
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        } else {
            firebaseManager.savePerformance(performance)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.setInputToDefault()
                        self.isLoading = false
                        switch completion {
                        case .finished:
                            self.toast = Toast(type: .success("Performance saved to Firebase!"))
                        case .failure(let error):
                            self.toast = Toast(type: .error(error))
                        }
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }

    private func setInputToDefault() {
        name = ""
        location = ""
        duration = ""
        storageType = .local
    }
}
