//
//  TokenManager.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "fairy_tales_access_token"
    private let refreshTokenKey = "fairy_tales_refresh_token"
    
    private init() {}
    
    // MARK: - Access Token
    var accessToken: String? {
        get {
            return getToken(for: accessTokenKey)
        }
        set {
            if let token = newValue {
                setToken(token, for: accessTokenKey)
            } else {
                deleteToken(for: accessTokenKey)
            }
        }
    }
    
    // MARK: - Refresh Token
    var refreshToken: String? {
        get {
            return getToken(for: refreshTokenKey)
        }
        set {
            if let token = newValue {
                setToken(token, for: refreshTokenKey)
            } else {
                deleteToken(for: refreshTokenKey)
            }
        }
    }
    
    // MARK: - Auth Headers
    var authHeaders: [String: String] {
        var headers: [String: String] = [:]
        
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    // MARK: - Clear All Tokens
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
    
    // MARK: - Keychain Operations
    private func setToken(_ token: String, for key: String) {
        let data = Data(token.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            // Silent failure - keychain operations can fail in various scenarios
        }
    }
    
    private func getToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteToken(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            // Silent failure - keychain operations can fail in various scenarios
        }
    }
}
