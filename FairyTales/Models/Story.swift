//
//  Story.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation

// MARK: - Story Request Model
struct StoryGenerateRequest: Codable {
    let story_name: String
    let story_idea: String
    let story_style: String
    let language: String
    let story_length: Int
    let heroes: [Hero]
}

// Legacy aliases for backward compatibility
typealias StoryCreateRequest = StoryGenerateRequest
typealias StoryGenerate = StoryGenerateRequest

// MARK: - Story Data Models
struct Story: Codable, Identifiable {
    let id: String?
    let user_id: String?
    let title: String
    let content: String?
    let hero_name: String?
    let hero_names: [String]?
    let age: Int?
    let story_style: String
    let language: String
    let story_idea: String?
    let story_length: Int?
    let child_gender: String?
    let created_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id = "user_id"
        case title, content
        case hero_name = "hero_name"
        case hero_names = "hero_names"
        case age
        case story_style = "story_style"
        case language
        case story_idea = "story_idea"
        case story_length = "story_length"
        case child_gender = "child_gender"
        case created_at = "created_at"
    }
}

// MARK: - Story Response Models
struct StoryResponse: Codable {
    let success: Bool
    let message: String?
    let data: StoryData?
}

struct StoryData: Codable {
    let story: Story
}

// MARK: - Story List Models (для MyStoriesScreen)
struct StoriesListResponse: Codable {
    let success: Bool
    let message: String?
    let data: StoriesListData?
}

struct StoriesListData: Codable {
    let stories: [Story]
    let total: Int?
    let skip: Int?
    let limit: Int?
}

// MARK: - Delete Story Models
struct DeleteStoryResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Story Styles and Languages

enum StoryStyle: String, Codable, CaseIterable {
    case adventure = "Adventure"
    case fantasy = "Fantasy"
    case educational = "Educational"
    case mystery = "Mystery"
    
    var localizedName: String {
        switch self {
        case .adventure:
            return "adventure".localized
        case .fantasy:
            return "fantasy".localized
        case .educational:
            return "educational".localized
        case .mystery:
            return "mystery".localized
        }
    }
}

// Use existing SupportedLanguage enum instead
typealias Language = SupportedLanguage

// MARK: - SSE Response Models
struct SSEMessage {
    let type: SSEMessageType
    let data: [String: Any]
}

enum SSEMessageType: String {
    case started
    case content
    case completed
    case error
}
