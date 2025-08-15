//
//  AuthManager.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import SwiftUI
import Observation
import AuthenticationServices

@Observable
@MainActor
final class AuthManager {
    static let shared = AuthManager()
    
    var isAuthenticated = false
    var currentUser: User?
    var isLoading = false
    var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    private init() {
        checkAuthStatus()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .authenticationExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🔐 Token expired, logging out user")
            Task { @MainActor in
                await self?.logout()
            }
        }
    }
    
    // MARK: - Authentication Status
    private func checkAuthStatus() {
        if let token = tokenManager.accessToken, !token.isEmpty {
            // Имеем токен - считаем что аутентифицированы
            isAuthenticated = true
            print("✅ Found saved token, user is authenticated")
        } else {
            isAuthenticated = false
            print("❌ No saved token found, user needs to login")
        }
    }
    
    // MARK: - Apple Sign In Only
    // Email/password authentication removed - Apple Sign In only
    
    // MARK: - Apple Sign In
    @MainActor
    func signInWithApple(authorization: ASAuthorization) async {
        print("🍎 AuthManager: signInWithApple called")
        clearError()
        isLoading = true
        
        print("🔍 AuthManager: Checking Apple credentials...")
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let _ = String(data: identityTokenData, encoding: .utf8),
              let authCodeData = appleIDCredential.authorizationCode,
              let _ = String(data: authCodeData, encoding: .utf8) else {
            print("❌ AuthManager: Failed to get Apple credentials")
            errorMessage = "Failed to get Apple credentials"
            isLoading = false
            return
        }
        
        print("✅ AuthManager: Apple credentials validated")
        print("👤 AuthManager: User ID: \(appleIDCredential.user)")
        
        let request = AppleSignInRequest(
            userIdentifier: appleIDCredential.user,
            fullName: appleIDCredential.fullName,
            email: appleIDCredential.email
        )
        
        do {
            print("🌐 AuthManager: Making Apple Sign In request to server...")
            let response: AuthResponse = try await networkManager.post(
                endpoint: request.endpoint,
                body: request,
                responseType: AuthResponse.self
            )
            
            print("📥 AuthManager: Server response received")
            print("✅ AuthManager: Response success: \(response.success)")
            print("👤 AuthManager: User: \(response.user?.displayName ?? "none")")
            
            if response.success, let user = response.user {
                print("🎉 AuthManager: Apple Sign In successful, handling auth...")
                await handleSuccessfulAuth(user: user, response: response)
                print("🏁 AuthManager: Auth handling completed")
            } else {
                print("❌ AuthManager: Apple Sign In failed: \(response.message ?? "unknown")")
                errorMessage = response.message ?? "Apple Sign In failed"
            }
        } catch {
            print("🚨 AuthManager: Apple Sign In threw error: \(error)")
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    @MainActor
    func logout() async {
        // Сначала очищаем локальные данные
        tokenManager.clearTokens()
        currentUser = nil
        isAuthenticated = false
        
        // Затем уведомляем сервер (необязательно)
        // TODO: Implement proper logout endpoint call when server supports it
        print("✅ Local logout completed")
    }
    
    // MARK: - Token Refresh
    func refreshToken() async -> Bool {
        guard let refreshToken = tokenManager.refreshToken else {
            await logout()
            return false
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        do {
            let response: AuthResponse = try await networkManager.post(
                endpoint: "/api/v1/auth/refresh/",
                body: request,
                responseType: AuthResponse.self
            )
            
            if response.success {
                await handleSuccessfulAuth(user: currentUser, response: response)
                return true
            } else {
                await logout()
                return false
            }
        } catch {
            await logout()
            return false
        }
    }
    
    // MARK: - Private Helpers
    @MainActor
    private func handleSuccessfulAuth(user: User?, response: AuthResponse) async {
        if let user = user {
            currentUser = user
        }
        
        if let accessToken = response.accessToken {
            tokenManager.accessToken = accessToken
        }
        
        if let refreshToken = response.refreshToken {
            tokenManager.refreshToken = refreshToken
        }
        
        isAuthenticated = true
    }
    
    private func handleAuthError(_ error: Error) {
        print("AuthManager: handleAuthError called with error: \(error)")
        
        if let networkError = error as? NetworkError {
            print("AuthManager: NetworkError detected: \(networkError)")
            switch networkError {
            case .apiError(let errorResponse):
                print("AuthManager: API Error - code: \(errorResponse.error_code ?? "NO_CODE"), message: \(errorResponse.message)")
                
                // Обрабатываем по стандартному коду ошибки
                if let errorCode = errorResponse.error_code,
                   let apiErrorCode = APIErrorCode(rawValue: errorCode) {
                    print("AuthManager: Processing standard API error: \(apiErrorCode)")
                    handleStandardAPIError(apiErrorCode, errorResponse: errorResponse)
                } else {
                    print("AuthManager: No standard error code, using fallback")
                    // Fallback на анализ сообщения для совместимости со старыми ответами
                    handleLegacyErrorMessage(errorResponse.message)
                }
                
            case .timeout:
                // Special handling for timeout during authentication
                print("⏰ Authentication timeout occurred")
                errorMessage = "auth_timeout_message".localized
                
            case .serverError(500):
                errorMessage = "server_error_suggestion".localized
            case .serverError(let code):
                errorMessage = "Server error (\(code)). Please try again later."
            default:
                print("🐛 Other NetworkError: \(networkError)")
                errorMessage = networkError.errorDescription
            }
        } else {
            print("🐛 Non-NetworkError: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func handleStandardAPIError(_ errorCode: APIErrorCode, errorResponse: ErrorResponse) {
        switch errorCode {
        case .userExists:
            print("✅ Standard: User already exists")
            errorMessage = "user_already_exists_suggestion".localized
            
        case .userNotFound:
            print("✅ Standard: User not found")
            errorMessage = "user_not_found_suggestion".localized
            
        case .invalidPassword:
            print("✅ Standard: Invalid password")
            // Показываем первое сообщение из errors или основное message
            errorMessage = errorResponse.errors.first ?? errorResponse.message
            
        case .validationError:
            print("✅ Standard: Validation error")
            // Показываем все ошибки валидации
            errorMessage = errorResponse.errors.joined(separator: "\n")
            
        case .tokenExpired:
            print("✅ Standard: Token expired")
            errorMessage = errorResponse.message
            // TODO: Автоматическое обновление токена
            
        case .internalError, .serviceUnavailable:
            print("✅ Standard: Server error")
            errorMessage = "server_error_suggestion".localized
            
        case .invalidAppleCredentials:
            print("✅ Standard: Invalid Apple credentials")
            errorMessage = errorResponse.message
        }
    }
    
    private func handleLegacyErrorMessage(_ message: String) {
        print("🔄 Fallback: Analyzing legacy message: '\(message)'")
        
        let lowerMessage = message.lowercased()
        
        if lowerMessage.contains("already exists") || 
           lowerMessage.contains("уже существует") {
            errorMessage = "user_already_exists_suggestion".localized
        } else if lowerMessage.contains("not found") || 
                  lowerMessage.contains("не найден") {
            errorMessage = "user_not_found_suggestion".localized
        } else if lowerMessage.contains("password") && 
                  (lowerMessage.contains("incorrect") || 
                   lowerMessage.contains("wrong") || 
                   lowerMessage.contains("invalid")) {
            errorMessage = message
        } else {
            errorMessage = message
        }
    }
    
    private func clearError() {
        errorMessage = nil
    }
}


