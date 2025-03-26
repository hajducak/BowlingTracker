import FirebaseFirestore
import Combine

struct CollectionNames {
    static let series: String = "series"
    static let users: String = "users"
}

protocol FirebaseServiceProtocol {
    associatedtype T: Codable

    func save(_ object: T, withID id: String) -> AnyPublisher<Void, AppError>
    func delete(id: String) -> AnyPublisher<Void, AppError>
}

class FirebaseService<T: Codable>: FirebaseServiceProtocol {
    let db: Firestore
    let collectionName: String

    init(db: Firestore = Firestore.firestore(), collectionName: String) {
        self.db = db
        self.collectionName = collectionName
    }

    func save(_ object: T, withID id: String) -> AnyPublisher<Void, AppError> {
        do {
            let data = try Firestore.Encoder().encode(object)
            return Future { promise in
                self.db.collection(self.collectionName)
                    .document(id)
                    .setData(data) { error in
                        if let error = error {
                            promise(.failure(.saveError(error)))
                        } else {
                            promise(.success(()))
                        }
                    }
            }.eraseToAnyPublisher()
        } catch {
            return Fail(error: .saveError(error)).eraseToAnyPublisher()
        }
    }

    func delete(id: String) -> AnyPublisher<Void, AppError> {
        return Future { promise in
            self.db.collection(self.collectionName).document(id).delete { error in
                if let error = error {
                    promise(.failure(.deletingError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
