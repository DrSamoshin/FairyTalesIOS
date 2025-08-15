//
//  APIProtocols.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation

// MARK: - API Protocols
protocol APIRequest: Codable {
    var endpoint: String { get }
}

protocol AuthenticationRequest: APIRequest {
    // Marker protocol for auth-related requests
}

// MARK: - Standard API Error Codes
enum APIErrorCode: String, CaseIterable {
    case userExists = "USER_EXISTS"
    case userNotFound = "USER_NOT_FOUND"
    case invalidPassword = "INVALID_PASSWORD"
    case validationError = "VALIDATION_ERROR"
    case tokenExpired = "TOKEN_EXPIRED"
    case internalError = "INTERNAL_ERROR"
    case serviceUnavailable = "SERVICE_UNAVAILABLE"
    case invalidAppleCredentials = "INVALID_APPLE_CREDENTIALS"
    
    // MARK: - Helper Properties
    var isRecoverable: Bool {
        switch self {
        case .userExists, .userNotFound, .invalidPassword, .validationError:
            return true
        case .tokenExpired:
            return true // Может быть обновлен автоматически
        case .internalError, .serviceUnavailable, .invalidAppleCredentials:
            return false
        }
    }
    
    var requiresUserAction: Bool {
        switch self {
        case .userExists, .userNotFound:
            return true // Предлагаем альтернативные действия
        case .invalidPassword, .validationError:
            return true // Пользователь должен исправить ввод
        case .tokenExpired:
            return false // Автоматическое обновление
        case .internalError, .serviceUnavailable, .invalidAppleCredentials:
            return false // Ничего не может сделать
        }
    }
}

// MARK: - Error Response Model
struct ErrorResponse: Codable {
    let success: Bool
    let message: String
    let errors: [String]
    let error_code: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, errors
        case error_code = "error_code"
    }
}
