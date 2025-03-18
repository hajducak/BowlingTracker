import Combine
@testable import BowlingTracker
import FirebaseFirestore
import Foundation

class MockSeriesFirebaseService: FirebaseService<Series> {
    private let mockFirestore: MockFirestore
    private let collectionName: String

    var shouldSucceed: Bool = true
    var error: AppError?
    var mockDocuments: [MockDocumentSnapshot]?
    
    init(mockFirestore: MockFirestore = MockFirestore(), collectionName: String) {
        self.mockFirestore = mockFirestore
        self.collectionName = collectionName
        super.init(collectionName: collectionName)
    }
    
    override func save(_ object: Series, withID id: String) -> AnyPublisher<Void, AppError> {
        if !shouldSucceed {
            return Fail(error: error ?? .customError("Mock save error")).eraseToAnyPublisher()
        }

        do {
            let data = try Firestore.Encoder().encode(object)
            return Future { promise in
                self.mockFirestore.collection(self.collectionName)
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
    
    override func fetchAll() -> AnyPublisher<[T], AppError> {
        if !shouldSucceed {
            return Fail(error: error ?? .customError("Mock fetch error")).eraseToAnyPublisher()
        }

        return Future<[T], AppError> { promise in
            if let mockDocuments = self.mockDocuments {
                let items = mockDocuments.compactMap { doc -> T? in
                    try? Firestore.Decoder().decode(T.self, from: doc.data)
                }
                promise(.success(items))
                return
            }

            self.mockFirestore.collection(self.collectionName).getDocuments { documents, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }

                let items = documents?.compactMap { doc -> T? in
                    try? Firestore.Decoder().decode(T.self, from: doc.data)
                } ?? []

                promise(.success(items))
            }
        }.eraseToAnyPublisher()
    }

    override func delete(id: String) -> AnyPublisher<Void, AppError> {
        if !shouldSucceed {
            return Fail(error: error ?? .customError("Mock delete error")).eraseToAnyPublisher()
        }

        return Future { promise in
            self.mockFirestore.collection(self.collectionName)
                .document(id)
                .delete { error in
                    if let error = error {
                        promise(.failure(.deletingError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}
