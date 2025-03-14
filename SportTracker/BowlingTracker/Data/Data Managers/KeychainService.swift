import Foundation
import Security

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case notFound
    case unexpectedData
}

final class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func saveCredentials(email: String, password: String) throws {
        let credentials = "\(email):\(password)".data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "BowlingTrackerCredentials",
            kSecValueData as String: credentials
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try updateCredentials(email: email, password: password)
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    func updateCredentials(email: String, password: String) throws {
        let credentials = "\(email):\(password)".data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "BowlingTrackerCredentials"
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: credentials
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    func getCredentials() throws -> (email: String, password: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "BowlingTrackerCredentials",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.notFound
        }
        
        guard let data = result as? Data,
              let credentials = String(data: data, encoding: .utf8),
              let separatorIndex = credentials.firstIndex(of: ":") else {
            throw KeychainError.unexpectedData
        }
        
        let email = String(credentials[..<separatorIndex])
        let password = String(credentials[credentials.index(after: separatorIndex)...])
        
        return (email: email, password: password)
    }
    
    func deleteCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "BowlingTrackerCredentials"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
} 
