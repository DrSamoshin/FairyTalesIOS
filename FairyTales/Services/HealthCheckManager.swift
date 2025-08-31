//
//  HealthCheckManager.swift
//  FairyTales
//
//  Created by Assistant on 08/08/2025.
//

import Foundation
import Observation

@Observable
@MainActor
final class HealthCheckManager {
    static let shared = HealthCheckManager()
    
    var isServerAvailable = true
    var lastHealthCheck: Date?
    var serverErrorMessage: String?
    var isCheckingHealth = false
    
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Health Check Methods
    func performHealthCheck() async {
        isCheckingHealth = true
        
        do {
            let response = try await networkManager.checkHealth()
            
            if response.success {
                isServerAvailable = true
                serverErrorMessage = nil
            } else {
                isServerAvailable = false
                serverErrorMessage = response.message ?? "server_unavailable".localized
            }
            
            lastHealthCheck = Date()
            
        } catch {
            isServerAvailable = false
            
            if let networkError = error as? NetworkError {
                switch networkError {
                case .timeout:
                    serverErrorMessage = "server_timeout".localized
                case .internetConnection:
                    serverErrorMessage = "no_internet_connection".localized
                case .serverError(let code):
                    serverErrorMessage = "server_error_code".localized + " (\(code))"
                default:
                    serverErrorMessage = "server_unavailable".localized
                }
            } else {
                serverErrorMessage = "server_unavailable".localized
            }
        }
        
        isCheckingHealth = false
    }
    
    // Perform health check with retry logic
    func performHealthCheckWithRetry(maxRetries: Int = 2) async {
        var attempts = 0
        
        while attempts < maxRetries {
            attempts += 1
            await performHealthCheck()
            
            if isServerAvailable {
                break
            }
            
            if attempts < maxRetries {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
    
    // Check if we need to perform health check (e.g., on app startup)
    func shouldPerformHealthCheck() -> Bool {
        guard let lastCheck = lastHealthCheck else {
            return true // Never checked before
        }
        
        // Perform health check if last check was more than 5 minutes ago
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        return lastCheck < fiveMinutesAgo
    }
    
    // Reset health status (useful for retry scenarios)
    func resetHealthStatus() {
        isServerAvailable = true
        serverErrorMessage = nil
        lastHealthCheck = nil
    }
}
