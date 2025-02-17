import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    private init() {}

    func savePerformance(_ performance: SportPerformance, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "id": performance.id,
            "name": performance.name,
            "location": performance.location,
            "duration": performance.duration,
            "storageType": performance.storageType
        ]
        
        db.collection("performances")
            .document(performance.id)
            .setData(data) { error in
                completion(error)
            }
    }

    func fetchPerformances(completion: @escaping ([SportPerformance]?, Error?) -> Void) {
        db.collection("performances")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let performances = snapshot?.documents.compactMap { doc -> SportPerformance? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let location = data["location"] as? String,
                          let duration = data["duration"] as? Int,
                          let storageType = data["storageType"] as? String else {
                        return nil
                    }
                    return SportPerformance(id: doc.documentID, name: name, location: location, duration: duration, storageType: storageType)
                }
                
                completion(performances, nil)
            }
    }
}
