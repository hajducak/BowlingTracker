import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<FirebaseAuth.User, AppError>
    func signUp(email: String, password: String) -> AnyPublisher<FirebaseAuth.User, AppError>
    func signOut() -> AnyPublisher<Void, AppError>
    func authentifiedUser() -> FirebaseAuth.User?
}

final class AuthService: AuthServiceProtocol {
    private let auth: Auth
    private let userService: UserFirebaseService
    private let seriesService: FirebaseService<Series>
    
    private var cancellables = Set<AnyCancellable>()
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
        self.userService = UserFirebaseService()
        self.seriesService = FirebaseService(collectionName: CollectionNames.series)
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<FirebaseAuth.User, AppError> {
        return Future<FirebaseAuth.User, AppError> { promise in
            self.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(.customError(error.localizedDescription)))
                    return
                }
                
                guard let user = result?.user else {
                    promise(.failure(.customError("Failed to get user data")))
                    return
                }
                
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String) -> AnyPublisher<FirebaseAuth.User, AppError> {
        return Future<FirebaseAuth.User, AppError> { promise in
            self.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(.customError(error.localizedDescription)))
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    promise(.failure(.customError("Failed to create user")))
                    return
                }
                
                let newUser = User(id: firebaseUser.uid, email: email)
                self.userService.saveUser(newUser)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    } receiveValue: {
                        promise(.success(firebaseUser))
                    }
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            do {
                try self.auth.signOut()
                promise(.success(()))
            } catch {
                promise(.failure(.customError(error.localizedDescription)))
            }
        }.eraseToAnyPublisher()
    }
    
    func authentifiedUser() -> FirebaseAuth.User? {
        return auth.currentUser
    }
    
    deinit {
        cancellables.removeAll()
    }
}
