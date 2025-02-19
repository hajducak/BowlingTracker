import FirebaseFirestore
import Combine

public class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    private let performancesCollection = "performances"
    private let seriesCollection = "series"
    
    public init() {}
    
    // MARK: - Bowling
    func saveSeries(_ series: Series) -> AnyPublisher<Void, AppError> {
        let documentID = UUID().uuidString
        var seriesToSave = series
        seriesToSave.id = documentID

        do {
            let data = try Firestore.Encoder().encode(seriesToSave)
            return Future<Void, AppError> { promise in
                self.db.collection(self.seriesCollection)
                    .document(documentID)
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

    func deleteSeries(id: String) -> AnyPublisher<Void, AppError> {
        return Future { [weak self] promise in
            self?.db.collection("series").document(id).delete { error in
                if let error = error {
                    promise(.failure(.deletingError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchAllSeries() -> AnyPublisher<[Series], AppError> {
        return Future<[Series], AppError> { promise in
            self.db.collection(self.seriesCollection).getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    promise(.success([]))
                    return
                }

                let seriesList = documents.compactMap { doc -> Series? in
                    try? doc.data(as: Series.self)
                }

                promise(.success(seriesList))
            }
        }.eraseToAnyPublisher()
    }

    func saveGameToSeries(seriesID: String, game: Game) -> AnyPublisher<Void, AppError> {
        let gameData: [String: Any]
        
        do {
            gameData = try Firestore.Encoder().encode(game)
        } catch {
            return Fail(error: .saveError(error)).eraseToAnyPublisher()
        }

        return Future<Void, AppError> { promise in
            let seriesRef = self.db.collection(self.seriesCollection).document(seriesID)

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
    
    // MARK: - Prformances
    func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, AppError> {
        let data: [String: Any] = [
            "id": performance.id,
            "name": performance.name,
            "location": performance.location,
            "duration": performance.duration,
            "storageType": performance.storageType
        ]
        
        return Future { [weak self] promise in
            guard let self else { return promise(.failure(.unknownError))}
            db.collection(performancesCollection)
                .document(performance.id)
                .setData(data) { error in
                    if let error = error {
                        promise(.failure(.saveError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func fetchPerformances() -> AnyPublisher<[SportPerformance], AppError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.customError("Self is nil")))
                return
            }
            self.db.collection("performances").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(.fetchingError(error)))
                    return
                }
                
                guard let snapshot = snapshot else {
                    promise(.failure(.customError("No Data Found")))
                    return
                }

                let performances = snapshot.documents.compactMap { doc -> SportPerformance? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let location = data["location"] as? String,
                          let duration = data["duration"] as? Int,
                          let storageType = data["storageType"] as? String else {
                        return nil
                    }
                    return SportPerformance(id: doc.documentID, name: name, location: location, duration: duration, storageType: storageType)
                }
                
                promise(.success(performances))
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteAllPerformances() -> AnyPublisher<Void, AppError> {
        return Future { [weak self] promise in
            self?.db.collection("performances").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(.deletingError(error)))
                    return
                }
                let batch = self?.db.batch()
                snapshot?.documents.forEach { batch?.deleteDocument($0.reference) }
                batch?.commit { batchError in
                    if let batchError = batchError {
                        promise(.failure(.deletingError(batchError)))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deletePerformance(with id: String) -> AnyPublisher<Void, AppError> {
        return Future { [weak self] promise in
            self?.db.collection("performances").document(id).delete { error in
                if let error = error {
                    promise(.failure(.deletingError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
