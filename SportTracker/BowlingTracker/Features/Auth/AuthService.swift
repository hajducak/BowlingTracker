import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<User, AppError>
    func signUp(email: String, password: String) -> AnyPublisher<User, AppError>
    func signOut() -> AnyPublisher<Void, AppError>
    func getCurrentUser() -> User?
}

final class AuthService: AuthServiceProtocol {
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, AppError> {
        return Future<User, AppError> { promise in
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
    
    func signUp(email: String, password: String) -> AnyPublisher<User, AppError> {
        return Future<User, AppError> { promise in
            self.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(.customError(error.localizedDescription)))
                    return
                }
                
                guard let user = result?.user else {
                    promise(.failure(.customError("Failed to create user")))
                    return
                }
                
                promise(.success(user))
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
    
    func getCurrentUser() -> User? {
        return auth.currentUser
    }
} 