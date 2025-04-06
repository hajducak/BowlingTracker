import Combine
import Foundation

final class BallViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    // private let userService: UserService
    
    let ball: Ball
    
    @Published var name: String
    @Published var imageUrl: URL?
    @Published var coreImageUrl: URL?
    
    init( // userService: UserService,
        ball: Ball) {
        // self.userService = userService
        self.ball = ball
        
        self.name = ball.name
        self.imageUrl = ball.imageUrl
    }
    
    deinit {
        cancellables.removeAll()
    }
}
