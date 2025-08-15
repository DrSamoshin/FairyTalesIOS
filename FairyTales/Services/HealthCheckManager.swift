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
    
    private init() {
        print("HealthCheckManager: Initializing HealthCheckManager")
        print("HealthCheckManager: Initial server status - isServerAvailable: \(isServerAvailable)")
        print("HealthCheckManager: NetworkManager reference: \(networkManager)")
    }
    
    // MARK: - Health Check Methods
    func performHealthCheck() async {
        print("HealthCheckManager: Starting health check...")
        isCheckingHealth = true
        
        do {
            print("HealthCheckManager: Making GET request to /api/v1/health/app/")
            let response = try await networkManager.checkHealth()
            
            print("HealthCheckManager: Health response received:")
            print("HealthCheckManager:   success: \(response.success)")
            print("HealthCheckManager:   message: \(response.message ?? "nil")")
            print("HealthCheckManager:   data.status: \(response.data?.status ?? "nil")")
            print("HealthCheckManager:   data.service: \(response.data?.service ?? "nil")")
            
            if response.success {
                print("HealthCheckManager: Server is healthy: \(response.message ?? "OK")")
                isServerAvailable = true
                serverErrorMessage = nil
            } else {
                print("HealthCheckManager: Server reports unhealthy: \(response.message ?? "Unknown error")")
                isServerAvailable = false
                serverErrorMessage = response.message ?? "server_unavailable".localized
            }
            
            lastHealthCheck = Date()
            print("HealthCheckManager: Updated lastHealthCheck to: \(lastHealthCheck!)")
            
        } catch {
            print("HealthCheckManager: Health check failed with error: \(error)")
            print("HealthCheckManager: Error type: \(type(of: error))")
            isServerAvailable = false
            
            // Handle different types of errors
            if let networkError = error as? NetworkError {
                print("HealthCheckManager: NetworkError details: \(networkError)")
                switch networkError {
                case .timeout:
                    serverErrorMessage = "server_timeout".localized
                    print("HealthCheckManager: Timeout error detected")
                case .internetConnection:
                    serverErrorMessage = "no_internet_connection".localized
                    print("HealthCheckManager: Internet connection error detected")
                case .serverError(let code):
                    serverErrorMessage = "server_error_code".localized + " (\(code))"
                    print("HealthCheckManager: Server error \(code) detected")
                default:
                    serverErrorMessage = "server_unavailable".localized
                    print("HealthCheckManager: Other network error detected")
                }
            } else {
                serverErrorMessage = "server_unavailable".localized
                print("HealthCheckManager: Non-network error detected")
            }
        }
        
        print("HealthCheckManager: Health check completed. Server available: \(isServerAvailable)")
        print("HealthCheckManager: Error message: \(serverErrorMessage ?? "none")")
        isCheckingHealth = false
    }
    
    // Perform health check with retry logic
    func performHealthCheckWithRetry(maxRetries: Int = 2) async {
        print("HealthCheckManager: Starting performHealthCheckWithRetry with \(maxRetries) max retries")
        var attempts = 0
        
        while attempts < maxRetries {
            attempts += 1
            print("HealthCheckManager: Health check attempt \(attempts)/\(maxRetries)")
            
            await performHealthCheck()
            
            // If server is available, break out of retry loop
            if isServerAvailable {
                print("HealthCheckManager: Server is available, stopping retries")
                break
            }
            
            if attempts < maxRetries {
                print("HealthCheckManager: Waiting 2 seconds before next retry...")
                // Wait before retry
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }
        
        print("HealthCheckManager: Health check with retry completed. Final result: isServerAvailable = \(isServerAvailable)")
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
