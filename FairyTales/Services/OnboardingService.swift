//
//  OnboardingService.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 04/09/2025.
//

import Foundation
import Observation

@Observable
@MainActor
final class OnboardingService {
    static let shared = OnboardingService()
    
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    var currentProgress: OnboardingProgress?
    var isLoading = false
    var lastError: NetworkError?
    
    private init() {}
    
    // MARK: - Get Onboarding Progress
    func getOnboardingProgress() async throws -> OnboardingProgress {
        guard let token = tokenManager.accessToken else {
            throw NetworkError.apiError(ErrorResponse(
                success: false,
                message: "Authentication required",
                errors: ["No access token"],
                error_code: "AUTH_REQUIRED"
            ))
        }
        
        isLoading = true
        lastError = nil
        
        do {
            let response: OnboardingResponse = try await networkManager.get(
                endpoint: "/api/v1/onboarding/progress",
                responseType: OnboardingResponse.self,
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            print("📊 OnboardingService: Server response - success: \(response.success)")
            print("📊 OnboardingService: Response message: \(response.message ?? "nil")")
            print("📊 OnboardingService: Data object: \(response.data != nil ? "exists" : "nil")")
            
            if let data = response.data {
                print("📊 OnboardingService: Steps count: \(data.steps.count)")
                for step in data.steps {
                    print("   - Step: \(step.stepName) at \(step.completedAt)")
                }
                
                let progress = OnboardingProgress(from: data.steps)
                print("📊 OnboardingService: Parsed progress:")
                print("   - accountCreated: \(progress.accountCreated)")
                print("   - firstHeroCreated: \(progress.firstHeroCreated)")  
                print("   - firstStoryCreated: \(progress.firstStoryCreated)")
                print("   - firstSeriesCreated: \(progress.firstSeriesCreated)")
                
                currentProgress = progress
                isLoading = false
                return progress
            }
            
            // If no data but success=true, means no steps completed yet
            let emptyProgress = OnboardingProgress(from: [])
            print("📊 OnboardingService: No data, using empty progress")
            currentProgress = emptyProgress
            isLoading = false
            return emptyProgress
        } catch {
            lastError = error as? NetworkError ?? NetworkError.unknown(error)
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Update Onboarding Step
    func updateOnboardingStep(_ step: OnboardingMilestone) async throws {
        guard let token = tokenManager.accessToken else {
            throw NetworkError.apiError(ErrorResponse(
                success: false,
                message: "Authentication required",
                errors: ["No access token"],
                error_code: "AUTH_REQUIRED"
            ))
        }
        
        isLoading = true
        lastError = nil
        
        let request = OnboardingUpdateRequest(step: step.rawValue)
        print("📤 Updating onboarding step: \(step.rawValue)")
        
        do {
            let response: OnboardingResponse = try await networkManager.post(
                endpoint: request.endpoint,
                body: request,
                responseType: OnboardingResponse.self,
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            if response.success {
                // Refresh progress after successful update
                _ = try await getOnboardingProgress()
                isLoading = false
            } else {
                let error = NetworkError.apiError(ErrorResponse(
                    success: false,
                    message: response.message ?? "Failed to update onboarding step",
                    errors: [],
                    error_code: nil
                ))
                lastError = error
                isLoading = false
                throw error
            }
        } catch {
            lastError = error as? NetworkError ?? NetworkError.unknown(error)
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Helper Methods
    func clearError() {
        lastError = nil
    }
    
    func isStepCompleted(_ step: OnboardingMilestone) -> Bool {
        guard let progress = currentProgress else { return false }
        
        switch step {
        case .accountCreated:
            return progress.accountCreated
        case .firstHeroCreated:
            return progress.firstHeroCreated
        case .firstStoryCreated:
            return progress.firstStoryCreated
        case .firstSeriesCreated:
            return progress.firstSeriesCreated
        }
    }
    
    var completedStepsCount: Int {
        guard let progress = currentProgress else { return 0 }
        
        var count = 0
        if progress.accountCreated { count += 1 }
        if progress.firstHeroCreated { count += 1 }
        if progress.firstStoryCreated { count += 1 }
        if progress.firstSeriesCreated { count += 1 }
        
        return count
    }
    
    var totalStepsCount: Int {
        return OnboardingMilestone.allCases.count
    }
    
    var progressPercentage: Double {
        return Double(completedStepsCount) / Double(totalStepsCount)
    }
    
    var isOnboardingCompleted: Bool {
        return completedStepsCount == totalStepsCount
    }
}