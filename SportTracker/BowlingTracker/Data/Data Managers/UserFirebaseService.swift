import FirebaseFirestore
import Combine
import FirebaseAuth

class UserFirebaseService: FirebaseService<User> {
    init() {
        super.init(collectionName: CollectionNames.users)
    }

    func saveUser(_ user: User) -> AnyPublisher<Void, AppError> {
        return save(user, withID: user.id)
    }
} 

class UserService: UserFirebaseService {
    private let authUser: FirebaseAuth.User

    init(authUser: FirebaseAuth.User) {
        self.authUser = authUser
    }
    
    func fetchUserData() -> AnyPublisher<User?, AppError> {
        return Future<User?, AppError> { promise in
            self.db.collection(self.collectionName)
                .document(self.authUser.uid)
                .getDocument { document, error in
                    if let error = error {
                        promise(.failure(.fetchingError(error)))
                        return
                    }
                    
                    guard let document = document, document.exists else {
                        promise(.success(nil))
                        return
                    }
                    
                    do {
                        let user = try document.data(as: User.self)
                        promise(.success(user))
                    } catch {
                        promise(.failure(.fetchingError(error)))
                    }
                }
        }.eraseToAnyPublisher()
    }
}
