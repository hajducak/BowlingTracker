import Foundation
@testable import BowlingTracker

class MockKeychainService {
    var savedCredentials: (email: String, password: String)?
    var shouldSucceed = true
    var error: Error?
    
    func saveCredentials(email: String, password: String) throws {
        if shouldSucceed {
            savedCredentials = (email: email, password: password)
        } else {
            throw error ?? KeychainError.unknown(errSecDuplicateItem)
        }
    }
    
    func getCredentials() throws -> (email: String, password: String) {
        if shouldSucceed, let credentials = savedCredentials {
            return credentials
        } else {
            throw error ?? KeychainError.notFound
        }
    }
    
    func deleteCredentials() throws {
        if shouldSucceed {
            savedCredentials = nil
        } else {
            throw error ?? KeychainError.unknown(errSecItemNotFound)
        }
    }
} 