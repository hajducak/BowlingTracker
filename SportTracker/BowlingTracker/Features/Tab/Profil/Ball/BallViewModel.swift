import Combine
import Foundation

enum BallViewContentType {
    case info
    case statistics
}

final class BallViewModel: ObservableObject, Identifiable {
    private var cancellables: Set<AnyCancellable> = []
    // private let userService: UserService
    
    let ball: Ball
    var onDismiss: (() -> Void)?
    
    @Published var contentType: BallViewContentType = .info
    
    @Published var name: String
    @Published var imageUrl: URL?
    @Published var coreImageUrl: URL?
    @Published var brand: String?
    @Published var coverstock: String?
    @Published var core: String?
    @Published var surface: String?
    @Published var rg: Double?
    @Published var diff: Double?
    @Published var weight: Int
    @Published var layout: String?
    @Published var lenght: Int?
    @Published var backend: Int?
    @Published var hook: Int?
    @Published var isSpareBall: Bool
    
    init( // userService: UserService,
        ball: Ball, onDismiss: (() -> Void)? = nil
    ) {
        self.ball = ball
        self.onDismiss = onDismiss
    // self.userService = userService
        
        self.name = ball.name
        self.imageUrl = ball.imageUrl
        self.coreImageUrl = ball.coreImageUrl
        self.brand = ball.brand
        self.coverstock = ball.coverstock
        self.core = ball.core
        self.surface = ball.surface
        self.rg = ball.rg
        self.diff = ball.diff
        self.weight = ball.weight
        self.layout = ball.layout
        self.lenght = ball.lenght
        self.backend = ball.backend
        self.hook = ball.hook
        self.isSpareBall = ball.isSpareBall ?? false
    }
    
    func close() {
        onDismiss?()
    }

    deinit {
        cancellables.removeAll()
    }
}
