import Combine
import Foundation

final class UserProfileViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @Published var user: User?
    @Published var showAddBallModal: Bool = false
    @Published var selectedBall: BallViewModel? = nil
    
    private let userService: UserService
    
    @Published var newProfileName = ""
    @Published var newHomeCenter = ""
    @Published var newStyle: BowlingStyle = .oneHanded
    @Published var newHand: HandStyle = .righty
    
    @Published var newBallName: String = ""
    @Published var newBallImageUrl: String = ""
    @Published var newBallIsSpareBall: Bool = false
    @Published var newBallBrand: String = ""
    @Published var newBallCoverstock: String = ""
    @Published var newBallRg: String = ""
    @Published var newBallDiff: String = ""
    @Published var newBallSurface: String = ""
    @Published var newBallWeight: String = ""
    @Published var newBallCore: String = ""
    @Published var newBallCoreImageUrl: String = ""
    @Published var newBallPinToPap: String = ""
    @Published var newBallLayout: String = ""
    @Published var newBallLenght: String = ""
    @Published var newBallBackend: String = ""
    @Published var newBallHook: String = ""
    
    init(userService: UserService) {
        self.userService = userService
        
        loadData()
        setupNotifications()
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
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showAddBall), name: .addBallRequested, object: nil)
    }
    
    @objc private func showAddBall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAddBallModal = true
        }
    }
    
    func updateUserProfile() {
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
        updateUser(user)
    }
    
    func addNewBall() {
        isLoading = true
        guard var user = self.user else { return }
        if user.balls == nil {
            user.balls = [Ball]()
        }
        user.balls?.insert(newBall(), at: 0)
        updateUser(user)
    }
    
    private func updateUser(_ user: User) {
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
    
    private func newBall() -> Ball {
        let rg: Double? = Double(newBallRg.replacingOccurrences(of: ",", with: "."))
        let diff: Double? = Double(newBallDiff.replacingOccurrences(of: ",", with: "."))
        let weight: Int = Int(newBallWeight) ?? 0
        let pinToPap: Double? = Double(newBallPinToPap.replacingOccurrences(of: ",", with: "."))
        let pictureUrl: URL? = URL(string: newBallImageUrl)
        let lenght: Int? = Int(newBallLenght)
        let backend: Int? = Int(newBallBackend)
        let hook: Int? = Int(newBallHook)
        let coreImageUrl: URL? = URL(string: newBallCoreImageUrl)
        let ball = Ball(
            imageUrl: pictureUrl,
            name: newBallName,
            brand: newBallBrand,
            coverstock: newBallCoverstock,
            rg: rg,
            diff: diff,
            surface: newBallSurface,
            weight: weight,
            core: newBallCore,
            coreImageUrl: coreImageUrl,
            pinToPap: pinToPap,
            layout: newBallLayout,
            lenght: lenght,
            backend: backend,
            hook: hook,
            isSpareBall: newBallIsSpareBall
        )
        resetBallParameters()
        return ball
    }
    
    private func resetBallParameters() {
        newBallName = ""
        newBallImageUrl = ""
        newBallBrand = ""
        newBallCoverstock = ""
        newBallRg = ""
        newBallDiff = ""
        newBallSurface = ""
        newBallWeight = ""
        newBallCore = ""
        newBallCoreImageUrl = ""
        newBallPinToPap = ""
        newBallLayout = ""
        newBallLenght = ""
        newBallBackend = ""
        newBallHook = ""
    }

    private func valueIfModified<T: Equatable>(_ newValue: T, _ oldValue: T) -> T? {
        return newValue == oldValue ? nil : newValue
    }
    
    func openDetail(_ ball: Ball) {
        selectedBall = BallViewModel(userService: userService, ball: ball, onDismiss: { [weak self] in
            self?.selectedBall = nil
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
    }
}
