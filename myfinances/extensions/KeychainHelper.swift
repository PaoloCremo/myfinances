//
//  APITokenManager.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-14.
//

import Security
import Foundation

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func save<T: Codable>(_ item: T, service: String, account: String) throws {
        let data = try JSONEncoder().encode(item)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed
        }
    }
    
    func read<T: Codable>(service: String, account: String) throws -> T {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.loadFailed
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    enum KeychainError: Error {
        case storeFailed
        case loadFailed
    }
}
