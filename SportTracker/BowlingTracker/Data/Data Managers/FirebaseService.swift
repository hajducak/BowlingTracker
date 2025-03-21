import FirebaseFirestore
import Combine

struct CollectionNames {
    static let series: String = "series"
}

protocol FirebaseServiceProtocol {
    associatedtype T: Codable

    func save(_ object: T, withID id: String) -> AnyPublisher<Void, AppError>
    func fetchAll() -> AnyPublisher<[T], AppError>
    func delete(id: String) -> AnyPublisher<Void, AppError>
}

class FirebaseService<T: Codable>: FirebaseServiceProtocol {
    private let db: Firestore
    private let collectionName: String

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

    func fetchAll() -> AnyPublisher<[T], AppError> {
        return Future<[T], AppError> { promise in
            self.db.collection(self.collectionName).getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }

                guard let documents = snapshot?.documents else {
                    promise(.success([]))
                    return
                }

                let items = documents.compactMap { doc -> T? in
                    try? doc.data(as: T.self)
                }

                promise(.success(items))
            }
        }.eraseToAnyPublisher()
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

extension FirebaseService where T == Series {
    func saveGameToSeries(seriesID: String, game: Game) -> AnyPublisher<Void, AppError> {
        let gameData: [String: Any]
        
        do {
            gameData = try Firestore.Encoder().encode(game)
        } catch {
            return Fail(error: .saveError(error)).eraseToAnyPublisher()
        }

        return Future<Void, AppError> { promise in
            let seriesRef = self.db.collection(self.collectionName).document(seriesID)

            seriesRef.getDocument { document, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }
                
                guard document?.exists == true else {
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

    func updateSeriesParameters(
        seriesID: String,
        date: Date? = nil,
        name: String? = nil,
        description: String? = nil,
        tag: SeriesType? = nil,
        oilPatternName: String? = nil,
        oilPatternURL: String? = nil,
        house: String? = nil
    ) -> AnyPublisher<Void, AppError> {
        return Future<Void, AppError> { promise in
            let seriesRef = self.db.collection(self.collectionName).document(seriesID)
            seriesRef.getDocument { document, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }
                
                guard let document = document, document.exists else {
                    promise(.failure(.customError("Series not found.")))
                    return
                }
                
                var updateData: [String: Any] = [:]
                if let date = date {
                    updateData["date"] = date
                }
                if let name = name {
                    updateData["name"] = name
                }
                if let description = description {
                    updateData["description"] = description
                }
                if let tag = tag {
                    updateData["tag"] = tag.rawValue
                }
                if let oilPatternName = oilPatternName {
                    updateData["oilPatternName"] = oilPatternName
                }
                if let oilPatternURL = oilPatternURL {
                    updateData["oilPatternURL"] = oilPatternURL
                }
                if let house = house {
                    updateData["house"] = house
                }

                guard !updateData.isEmpty else {
                    promise(.success(()))
                    return
                }

                seriesRef.updateData(updateData) { error in
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
