//
//  LegalManager.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 15/08/2025.
//

import Foundation
import Observation

@Observable
@MainActor
final class LegalManager {
    static let shared = LegalManager()
    
    var isLoading = false
    var errorMessage: String?
    var privacyPolicy: LegalContent?
    var termsOfService: LegalContent?
    
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Privacy Policy
    func loadPrivacyPolicy() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let legalContent = try await networkManager.getPrivacyPolicy()
            privacyPolicy = legalContent
            print("Privacy Policy loaded successfully")
        } catch {
            errorMessage = "Failed to load Privacy Policy"
            print("Privacy Policy network error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Terms of Service
    func loadTermsOfService() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let legalContent = try await networkManager.getTermsOfService()
            termsOfService = legalContent
            print("Terms of Service loaded successfully")
        } catch {
            errorMessage = "Failed to load Terms of Service"
            print("Terms of Service network error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    func clearError() {
        errorMessage = nil
    }
    
    func hasPrivacyPolicy() -> Bool {
        return privacyPolicy != nil
    }
    
    func hasTermsOfService() -> Bool {
        return termsOfService != nil
    }
}
