import FirebaseFirestore
import Combine

public class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    public init() {}

    func savePerformance(_ performance: SportPerformance) -> AnyPublisher<Void, Error> {
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
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func fetchPerformances() -> AnyPublisher<[SportPerformance], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirebaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            self.db.collection("performances").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    promise(.failure(NSError(domain: "FirebaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
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
}
