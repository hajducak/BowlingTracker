import Combine
import Foundation

final class UserProfileViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @Published var user: User?
    
    private let userService: UserService
    
    @Published var newProfileName = ""
    @Published var newHomeCenter = ""
    @Published var newStyle: BowlingStyle = .oneHanded
    @Published var newHand: HandStyle = .righty
    @Published var newBall: Ball? = nil
    
    init(userService: UserService) {
        self.userService = userService
        
        loadData()
    }
    
    private func loadData() {
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
                self.newProfileName = user?.name ?? ""
                self.newHomeCenter = user?.homeCenter ?? ""
                self.newStyle = user?.style ?? .oneHanded
                self.newHand = user?.hand ?? .righty
            }.store(in: &cancellables)
    }
    
    func updateUser() {
        isLoading = true
        guard var user = self.user else { return }
        if let name = valueIfModified(newProfileName, user.name) {
            user.name = name
        }
        if let homeCenter = valueIfModified(newHomeCenter, user.homeCenter) {
            user.homeCenter = homeCenter
        }
        if let style = valueIfModified(newStyle, user.style) {
            user.style = style
        }
        if let hand = valueIfModified(newHand, user.hand) {
            user.hand = hand
        }
        if let ball = newBall {
            user.balls?.append(ball)
        }
        userService.saveUser(user)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
                isLoading = false
            } receiveValue: { [weak self] user in
                guard let self else { return }
                loadData()
            }.store(in: &cancellables)
    }
    
    private func valueIfModified<T: Equatable>(_ newValue: T, _ oldValue: T) -> T? {
        return newValue == oldValue ? nil : newValue
    }
    
    deinit {
        cancellables.removeAll()
    }
}
