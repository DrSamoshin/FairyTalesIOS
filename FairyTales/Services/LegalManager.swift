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
        } catch {
            errorMessage = "Failed to load Privacy Policy"
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
        } catch {
            errorMessage = "Failed to load Terms of Service"
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
