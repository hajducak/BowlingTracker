import Combine
@testable import BowlingTracker
import FirebaseFirestore
import Foundation

class MockFirestore {
    var collections: [String: [String: [String: Any]]] = [:]

    func collection(_ name: String) -> MockCollectionReference {
        if collections[name] == nil {
            collections[name] = [:]
        }
        return MockCollectionReference(collectionName: name, firestore: self)
    }
}

class MockCollectionReference {
    private let collectionName: String
    private let firestore: MockFirestore

    init(collectionName: String, firestore: MockFirestore) {
        self.collectionName = collectionName
        self.firestore = firestore
    }

    func document(_ id: String) -> MockDocumentReference {
        return MockDocumentReference(collectionName: collectionName, documentID: id, firestore: firestore)
    }

    func getDocuments(completion: @escaping ([MockDocumentSnapshot]?, Error?) -> Void) {
        let documents = firestore.collections[collectionName]?.map { (id, data) in
            MockDocumentSnapshot(id: id, data: data)
        } ?? []
        completion(documents, nil)
    }
}

class MockDocumentReference {
    private let collectionName: String
    private let documentID: String
    private let firestore: MockFirestore

    init(collectionName: String, documentID: String, firestore: MockFirestore) {
        self.collectionName = collectionName
        self.documentID = documentID
        self.firestore = firestore
    }

    func setData(_ data: [String: Any], completion: ((Error?) -> Void)?) {
        firestore.collections[collectionName]?[documentID] = data
        completion?(nil)
    }

    func delete(completion: ((Error?) -> Void)?) {
        firestore.collections[collectionName]?.removeValue(forKey: documentID)
        completion?(nil)
    }

    func getDocument(completion: @escaping (MockDocumentSnapshot?, Error?) -> Void) {
        if let data = firestore.collections[collectionName]?[documentID] {
            completion(MockDocumentSnapshot(id: documentID, data: data), nil)
        } else {
            completion(nil, nil)
        }
    }

    func updateData(_ data: [String: Any], completion: @escaping (Error?) -> Void) {
        guard var currentData = firestore.collections[collectionName]?[documentID] as? [String: Any] else {
            firestore.collections[collectionName]?[documentID] = data
            completion(nil)
            return
        }

        if let games = data["games"] as? [[String: Any]], 
           let currentGames = currentData["games"] as? [[String: Any]] {
            currentData["games"] = currentGames + games
        } else {
            for (key, value) in data {
                currentData[key] = value
            }
        }
        
        firestore.collections[collectionName]?[documentID] = currentData
        completion(nil)
    }
}

class MockDocumentSnapshot {
    let id: String
    let data: [String: Any]

    init(id: String, data: [String: Any]) {
        self.id = id
        self.data = data
    }
}
