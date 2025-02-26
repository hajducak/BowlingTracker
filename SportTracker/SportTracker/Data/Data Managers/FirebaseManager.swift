import FirebaseFirestore
import Combine

public class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    private let performancesCollection = "performances"
    private let seriesCollection = "series"
    
    public init() {}
    
    func saveSeries(_ series: Series) -> AnyPublisher<Void, AppError> {
        do {
            let data = try Firestore.Encoder().encode(series)
            return Future<Void, AppError> { promise in
                self.db.collection(self.seriesCollection)
                    .document(series.id)
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
}
