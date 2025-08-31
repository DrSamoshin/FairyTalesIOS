//
//  HeroService.swift
//  FairyTales
//
//  Created by Assistant on 29/08/2025.
//

import Foundation
import Observation

@Observable
@MainActor
final class HeroService {
    static let shared = HeroService()
    
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    // MARK: - Published State
    var isLoading = false
    var errorMessage: String?
    var heroes: [Hero] = []
    
    private init() {}
    
    // MARK: - Hero Creation
    func createHero(request: HeroCreateRequest) async -> Hero? {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            
            
            let response: HeroResponse = try await networkManager.post(
                endpoint: "/api/v1/heroes/",
                body: request,
                responseType: HeroResponse.self,
                headers: headers
            )
            
            if response.success, let newHero = response.data {
                heroes.append(newHero)
                
                // Send notification for other parts of the app
                NotificationCenter.default.post(name: NSNotification.Name("HeroCreated"), object: nil)
                
                isLoading = false
                return newHero
            } else {
                errorMessage = response.message ?? "Failed to create hero"
                isLoading = false
                return nil
            }
        } catch {
            handleError(error)
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Hero Update
    func updateHero(heroId: String, request: HeroUpdateRequest) async -> Hero? {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            let response: HeroResponse = try await networkManager.put(
                endpoint: "/api/v1/heroes/\(heroId)/",
                body: request,
                responseType: HeroResponse.self,
                headers: headers
            )
            
            if response.success, let updatedHero = response.data {
                // Update hero in local array
                if let index = heroes.firstIndex(where: { $0.id == heroId }) {
                    heroes[index] = updatedHero
                }
                
                // Send notification for other parts of the app
                NotificationCenter.default.post(name: NSNotification.Name("HeroUpdated"), object: nil)
                
                isLoading = false
                return updatedHero
            } else {
                errorMessage = response.message ?? "Failed to update hero"
                isLoading = false
                return nil
            }
        } catch {
            handleError(error)
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Hero Management
    func fetchUserHeroes() async -> [Hero] {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            let response: HeroesListResponse = try await networkManager.get(
                endpoint: "/api/v1/heroes/",
                responseType: HeroesListResponse.self,
                headers: headers
            )
            
            if response.success, let heroesData = response.data {
                print("Fetched \(heroesData.heroes.count) heroes successfully")
                heroes = heroesData.heroes
                isLoading = false
                return heroesData.heroes
            } else {
                errorMessage = response.message ?? "Failed to fetch heroes"
                isLoading = false
                return []
            }
        } catch {
            handleError(error)
            isLoading = false
            return []
        }
    }
    
    func deleteHero(heroId: String) async -> Bool {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            let response: DeleteHeroResponse = try await networkManager.delete(
                endpoint: "/api/v1/heroes/\(heroId)/",
                responseType: DeleteHeroResponse.self,
                headers: headers
            )
            
            if response.success {
                print("Hero deleted successfully")
                heroes.removeAll { $0.id == heroId }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("HeroDeleted"), object: nil)
                }
                isLoading = false
                return true
            } else {
                errorMessage = response.message ?? "Failed to delete hero"
                isLoading = false
                return false
            }
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - State Management
    private func clearError() {
        errorMessage = nil
    }
    
    func clearHeroes() {
        heroes.removeAll()
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let errorResponse):
                print("Hero API Error: \(errorResponse.error_code ?? "NO_CODE") - \(errorResponse.message)")
                
                if let errorCode = errorResponse.error_code,
                   let apiErrorCode = APIErrorCode(rawValue: errorCode) {
                    handleStandardAPIError(apiErrorCode, errorResponse: errorResponse)
                } else {
                    errorMessage = errorResponse.message
                }
                
            case .timeout:
                print("⏰ Hero operation timeout")
                errorMessage = "Request timeout. Please try again."
                
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
        case .tokenExpired:
            print("Standard: Token expired")
            errorMessage = "Please login again"
            
        case .validationError:
            print("Standard: Validation error")
            errorMessage = errorResponse.errors.joined(separator: "\n")
            
        case .internalError, .serviceUnavailable:
            print("Standard: Server error")
            errorMessage = "server_error_suggestion".localized
            
        default:
            errorMessage = errorResponse.message
        }
    }
}