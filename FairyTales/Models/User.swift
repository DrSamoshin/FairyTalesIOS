//
//  User.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let name: String?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Computed Properties
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        } else if let email = email, !email.isEmpty {
            return email.components(separatedBy: "@").first ?? "User"
        } else {
            return "User"
        }
    }
    
    var isActiveUser: Bool {
        return isActive ?? false
    }
}

// MARK: - Auth Request Models
struct EmailLoginRequest: AuthenticationRequest {
    let email: String
    let password: String
    
    var endpoint: String { "/api/v1/auth/login/" }
}

struct EmailRegisterRequest: AuthenticationRequest {
    let email: String
    let password: String
    let name: String
    
    var endpoint: String { "/api/v1/auth/register/" }
}

struct AppleSignInRequest: AuthenticationRequest {
    let apple_id: String
    let name: String
    let identity_token: String?
    
    var endpoint: String { "/api/v1/auth/apple-signin/" }
    
    init(userIdentifier: String, fullName: PersonNameComponents? = nil, email: String? = nil, identityToken: String? = nil) {
        self.apple_id = userIdentifier
        self.name = Self.extractName(from: fullName, email: email)
        self.identity_token = identityToken
    }
    
    private static func extractName(from fullName: PersonNameComponents?, email: String?) -> String {
        if let fullName = fullName {
            let firstName = fullName.givenName ?? ""
            let lastName = fullName.familyName ?? ""
            let combinedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            return combinedName.isEmpty ? "Apple User" : combinedName
        } else if let email = email {
            return email.components(separatedBy: "@").first ?? "Apple User"
        } else {
            return "Apple User"
        }
    }
}

// MARK: - Auth Response Models
struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let data: AuthData?
    let error_code: String?
    
    var user: User? {
        return data?.user
    }
    
    var accessToken: String? {
        return data?.token?.access_token
    }
    
    var refreshToken: String? {
        return data?.token?.refresh_token
    }
}

struct AuthData: Codable {
    let user: User?
    let token: TokenData?
}

struct TokenData: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}


