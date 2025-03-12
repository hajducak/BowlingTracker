import Combine
@testable import BowlingTracker
import FirebaseFirestore
import Foundation

class MockFirebaseService<T: Codable>: FirebaseServiceProtocol {
    private let mockFirestore: MockFirestore
    private let collectionName: String

    init(mockFirestore: MockFirestore, collectionName: String) {
        self.mockFirestore = mockFirestore
        self.collectionName = collectionName
    }

    func save(_ object: T, withID id: String) -> AnyPublisher<Void, AppError> {
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

    func fetchAll() -> AnyPublisher<[T], AppError> {
        return Future<[T], AppError> { promise in
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

    func delete(id: String) -> AnyPublisher<Void, AppError> {
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

extension MockFirebaseService where T == Series {
    func saveGameToSeries(seriesID: String, game: Game) -> AnyPublisher<Void, AppError> {
        let gameData: [String: Any]
        
        do {
            gameData = try Firestore.Encoder().encode(game)
        } catch {
            return Fail(error: .saveError(error)).eraseToAnyPublisher()
        }

        return Future<Void, AppError> { promise in
            let seriesRef = self.mockFirestore.collection(self.collectionName).document(seriesID)

            seriesRef.getDocument { document, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }
                
                guard document?.data != nil else {
                    promise(.failure(.customError("Series not found.")))
                    return
                }

                seriesRef.updateData([
                    "games": FieldValue.arrayUnion([gameData])
                ]) { error in
                    if let error = error {
                        promise(.failure(.saveError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
