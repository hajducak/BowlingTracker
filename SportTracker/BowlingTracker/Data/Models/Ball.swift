import Foundation
struct Ball: Codable, Identifiable {
    var id: String = UUID().uuidString
    let imageUrl: URL?
    let name: String
    let brand: String?
    let coverstock: String?
    let rg: Double?
    let diff: Double?
    let surface: String?
    let weight: Int
    let core: String?
    let coreImageUrl: URL?
    let pinToPap: Double?
    let layout: String?
    let lenght: Int?
    let backend: Int?
    let hook: Int?
    let isSpareBall: Bool?
}

