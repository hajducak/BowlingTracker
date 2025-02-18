import FirebaseFirestore
import Combine

public class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    public init() {}

    func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, AppError> {
        let data: [String: Any] = [
            "id": performance.id,
            "name": performance.name,
            "location": performance.location,
            "duration": performance.duration,
            "storageType": performance.storageType
        ]
        
        return Future { [weak self] promise in
            self?.db.collection("performances")
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
