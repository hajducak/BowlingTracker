import Combine
import Foundation

final class UserProfileViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @Published var user: User?
    
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
        
        loadData()
    }
    
    func loadData() {
        isLoading = true
        userService.fetchUserData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
                isLoading = false
            } receiveValue: { [weak self] user in
                guard let self else { return }
                self.user = user
            }.store(in: &cancellables)
    }
    
    deinit {
        cancellables.removeAll()
    }
}
