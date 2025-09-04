//
//  Onboarding.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 04/09/2025.
//

import Foundation

// MARK: - Onboarding Models
struct OnboardingStepData: Codable {
    let id: String
    let userId: String
    let stepName: String
    let completedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stepName = "step_name"
        case completedAt = "completed_at"
    }
}

struct OnboardingData: Codable {
    let userId: String
    let steps: [OnboardingStepData]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case steps
    }
}

struct OnboardingResponse: Codable {
    let success: Bool
    let message: String?
    let data: OnboardingData?
}

// MARK: - Helper struct for easier access
struct OnboardingProgress {
    let accountCreated: Bool
    let firstHeroCreated: Bool
    let firstStoryCreated: Bool
    let firstSeriesCreated: Bool
    
    init(from steps: [OnboardingStepData]) {
        let stepNames = Set(steps.map { $0.stepName })
        
        self.accountCreated = stepNames.contains("account_created")
        self.firstHeroCreated = stepNames.contains("first_hero_created")
        self.firstStoryCreated = stepNames.contains("first_story_created")
        self.firstSeriesCreated = stepNames.contains("first_series_created")
    }
}

struct OnboardingUpdateRequest: Codable {
    let step: String
    
    var endpoint: String { "/api/v1/onboarding/step" }
}

// MARK: - Onboarding Milestone Enum
enum OnboardingMilestone: String, CaseIterable {
    case accountCreated = "account_created"
    case firstHeroCreated = "first_hero_created"
    case firstStoryCreated = "first_story_created"
    case firstSeriesCreated = "first_series_created"
    
    var displayName: String {
        switch self {
        case .accountCreated:
            return "Account Created"
        case .firstHeroCreated:
            return "First Hero Created"
        case .firstStoryCreated:
            return "First Story Created"
        case .firstSeriesCreated:
            return "First Series Created"
        }
    }
}