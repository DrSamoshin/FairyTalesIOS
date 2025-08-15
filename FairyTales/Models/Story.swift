//
//  Story.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation

// MARK: - Story Request Models
struct StoryCreateRequest: APIRequest {
    let story_name: String
    let hero_name: String
    let age: Int
    let story_style: String
    let language: String
    let story_idea: String
    
    var endpoint: String { "/api/v1/stories/generate/" }
}

struct StoryStreamRequest: APIRequest {
    let story_name: String
    let hero_name: String
    let age: Int
    let story_style: String
    let language: String
    let story_idea: String
    
    var endpoint: String { "/api/v1/stories/generate-stream/" }
}

// MARK: - Streaming Response Models
struct StreamChunk: Codable {
    let type: String
    let data: StreamData?
}

struct StreamData: Codable {
    let title: String?
    let content: String?
    let chunk: String?
    let completed: Bool?
    let story_id: String?
}

// MARK: - Story Data Models
struct Story: Codable, Identifiable {
    let id: String?
    let title: String
    let content: String
    let language: String
    let story_style: String
    let hero_name: String?
    let age: Int?
    let created_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, language
        case story_style = "story_style"
        case hero_name = "hero_name"
        case age
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
    let page: Int?
    let per_page: Int?
}

// MARK: - Delete Story Models
struct DeleteStoryResponse: Codable {
    let success: Bool
    let message: String?
}
