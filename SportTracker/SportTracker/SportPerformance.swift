import SwiftData
import Foundation
import FirebaseFirestore

@Model
class SportPerformance {
    @Attribute(.unique) var id: String
    var name: String
    var location: String
    var duration: Int
    var storageType: String

    init(id: String = UUID().uuidString, name: String, location: String, duration: Int, storageType: String) {
        self.id = id
        self.name = name
        self.location = location
        self.duration = duration
        self.storageType = storageType
    }
}

enum StorageType: String, Codable {
    case local, remote
}
