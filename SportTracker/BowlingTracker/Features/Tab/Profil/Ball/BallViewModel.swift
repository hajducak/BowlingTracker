import Combine
import Foundation

final class BallViewModel: ObservableObject, Identifiable {
    private var cancellables: Set<AnyCancellable> = []
    // private let userService: UserService
    
    let ball: Ball
    var onDismiss: (() -> Void)?
    
    @Published var name: String
    @Published var imageUrl: URL?
    @Published var coreImageUrl: URL?
    
    init( // userService: UserService,
        ball: Ball, onDismiss: (() -> Void)? = nil
    ) {
        self.ball = ball
        self.onDismiss = onDismiss
    // self.userService = userService
        
        self.name = ball.name
        self.imageUrl = ball.imageUrl
        self.coreImageUrl = ball.coreImageUrl
    }
    
    func close() {
        onDismiss?()
    }

    deinit {
        cancellables.removeAll()
    }
}
