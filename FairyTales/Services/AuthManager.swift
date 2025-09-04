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
    private let onboardingService = OnboardingService.shared
    
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
            print("Token expired, logging out user")
            Task { @MainActor in
                await self?.logout()
            }
        }
    }
    
    // MARK: - Authentication Status
    private func checkAuthStatus() {
        isAuthenticated = tokenManager.accessToken != nil && !tokenManager.accessToken!.isEmpty
    }
    
    // MARK: - Apple Sign In Only
    // Email/password authentication removed - Apple Sign In only
    
    // MARK: - Apple Sign In
    @MainActor
    func signInWithApple(authorization: ASAuthorization) async {
        clearError()
        isLoading = true
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let identityTokenString = String(data: identityTokenData, encoding: .utf8),
              let authCodeData = appleIDCredential.authorizationCode,
              let _ = String(data: authCodeData, encoding: .utf8) else {
            errorMessage = "Failed to get Apple credentials"
            isLoading = false
            return
        }
        
        let request = AppleSignInRequest(
            userIdentifier: appleIDCredential.user,
            fullName: appleIDCredential.fullName,
            email: appleIDCredential.email,
            identityToken: identityTokenString
        )
        
        do {
            let response: AuthResponse = try await networkManager.post(
                endpoint: request.endpoint,
                body: request,
                responseType: AuthResponse.self
            )
            
            if response.success, let user = response.user {
                await handleSuccessfulAuth(user: user, response: response)
            } else {
                errorMessage = response.message ?? "Apple Sign In failed"
            }
        } catch {
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Account Deletion
    @MainActor
    func deleteAccount() async throws {
        guard let token = tokenManager.accessToken else {
            throw NetworkError.apiError(ErrorResponse(
                success: false,
                message: "Authentication required",
                errors: ["No access token"],
                error_code: "AUTH_REQUIRED"
            ))
        }
        
        isLoading = true
        clearError()
        
        do {
            let response: DeleteAccountResponse = try await networkManager.delete(
                endpoint: "/api/v1/users/delete",
                responseType: DeleteAccountResponse.self,
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            if response.success {
                // Account deleted successfully, logout user
                await logout()
                isLoading = false
            } else {
                errorMessage = response.message ?? "Failed to delete account"
                isLoading = false
                throw NetworkError.apiError(ErrorResponse(
                    success: false,
                    message: response.message ?? "Failed to delete account",
                    errors: [],
                    error_code: nil
                ))
            }
        } catch {
            handleAuthError(error)
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Logout
    @MainActor
    func logout() async {
        tokenManager.clearTokens()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Token Refresh
    func refreshToken() async -> Bool {
        guard let refreshToken = tokenManager.refreshToken else {
            await logout()
            return false
        }
        
        let headers = ["Authorization": "Bearer \(refreshToken)"]
        
        do {
            let response: AuthResponse = try await networkManager.get(
                endpoint: "/api/v1/auth/refresh/",
                responseType: AuthResponse.self,
                headers: headers
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
        
        // Load onboarding progress
        Task {
            try? await onboardingService.getOnboardingProgress()
        }
    }
    
    private func handleAuthError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let errorResponse):
                if let errorCode = errorResponse.error_code,
                   let apiErrorCode = APIErrorCode(rawValue: errorCode) {
                    handleStandardAPIError(apiErrorCode, errorResponse: errorResponse)
                } else {
                    handleLegacyErrorMessage(errorResponse.message)
                }
                
            case .timeout:
                errorMessage = "auth_timeout_message".localized
                
            case .serverError(500):
                errorMessage = "server_error_suggestion".localized
            case .serverError(let code):
                errorMessage = "Server error (\(code)). Please try again later."
            default:
                errorMessage = networkError.errorDescription
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    private func handleStandardAPIError(_ errorCode: APIErrorCode, errorResponse: ErrorResponse) {
        switch errorCode {
        case .userExists:
            errorMessage = "user_already_exists_suggestion".localized
        case .userNotFound:
            errorMessage = "user_not_found_suggestion".localized
        case .invalidPassword:
            errorMessage = errorResponse.errors.first ?? errorResponse.message
        case .validationError:
            errorMessage = errorResponse.errors.joined(separator: "\n")
        case .tokenExpired:
            errorMessage = errorResponse.message
        case .internalError, .serviceUnavailable:
            errorMessage = "server_error_suggestion".localized
        case .invalidAppleCredentials:
            errorMessage = errorResponse.message
        }
    }
    
    private func handleLegacyErrorMessage(_ message: String) {
        let lowerMessage = message.lowercased()
        
        if lowerMessage.contains("already exists") || 
           lowerMessage.contains("уже существует") {
            errorMessage = "user_already_exists_suggestion".localized
        } else if lowerMessage.contains("not found") || 
                  lowerMessage.contains("не найден") {
            errorMessage = "user_not_found_suggestion".localized
        } else {
            errorMessage = message
        }
    }
    
    private func clearError() {
        errorMessage = nil
    }
}


