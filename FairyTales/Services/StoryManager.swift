//
//  StoryManager.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Observation

@available(*, deprecated, message: "Use StoryService instead for unified story generation")
@Observable
@MainActor
final class StoryManager {
    static let shared = StoryManager()
    
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    var isLoading = false
    var errorMessage: String?
    var currentStory: Story?
    
    private init() {}
    
    // MARK: - Story Generation
    func generateStory(
        storyName: String,
        heroName: String,
        age: Int,
        storyStyle: String,
        language: String,
        storyIdea: String
    ) async -> Story? {
        clearError()
        isLoading = true
        
        let request = StoryCreateRequest(
            story_name: storyName,
            hero_name: heroName,
            story_idea: storyIdea,
            story_style: storyStyle,
            language: language,
            age: age,
            story_length: 3, // Default medium length for backward compatibility
            child_gender: "boy" // Default gender for backward compatibility
        )
        
        do {
            let headers = tokenManager.authHeaders
            let response: StoryResponse = try await networkManager.post(
                endpoint: "/api/v1/stories/generate/",
                body: request,
                responseType: StoryResponse.self,
                headers: headers
            )
            
            if response.success, let story = response.data?.story {
                currentStory = story
                print("✅ Story generated successfully: \(story.title)")
                isLoading = false
                return story
            } else {
                errorMessage = response.message ?? "Failed to generate story"
                isLoading = false
                return nil
            }
        } catch {
            handleStoryError(error)
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Error Handling
    private func handleStoryError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let errorResponse):
                print("🎯 Story API Error: \(errorResponse.error_code ?? "NO_CODE") - \(errorResponse.message)")
                
                if let errorCode = errorResponse.error_code,
                   let apiErrorCode = APIErrorCode(rawValue: errorCode) {
                    handleStandardAPIError(apiErrorCode, errorResponse: errorResponse)
                } else {
                    errorMessage = errorResponse.message
                }
                
            case .timeout:
                // Special handling for timeout - show helpful message about background generation
                print("⏰ Story generation timeout - may still be processing")
                errorMessage = "story_timeout_message".localized
                
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
            print("✅ Standard: Token expired")
            errorMessage = "Please login again"
            // TODO: Автоматическое обновление токена
            
        case .validationError:
            print("✅ Standard: Validation error")
            errorMessage = errorResponse.errors.joined(separator: "\n")
            
        case .internalError, .serviceUnavailable:
            print("✅ Standard: Server error")
            errorMessage = "server_error_suggestion".localized
            
        default:
            errorMessage = errorResponse.message
        }
    }
    
    private func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Story Management
    func fetchUserStories() async -> [Story] {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            let response: StoriesListResponse = try await networkManager.get(
                endpoint: "/api/v1/stories/",
                responseType: StoriesListResponse.self,
                headers: headers
            )
            
            if response.success, let storiesData = response.data {
                print("✅ Fetched \(storiesData.stories.count) stories successfully")
                isLoading = false
                return storiesData.stories
            } else {
                errorMessage = response.message ?? "Failed to fetch stories"
                isLoading = false
                return []
            }
        } catch {
            handleStoryError(error)
            isLoading = false
            return []
        }
    }
    
    func deleteStory(storyId: String) async -> Bool {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            let response: DeleteStoryResponse = try await networkManager.delete(
                endpoint: "/api/v1/stories/\(storyId)/",
                responseType: DeleteStoryResponse.self,
                headers: headers
            )
            
            if response.success {
                print("✅ Story deleted successfully")
                // Очищаем текущую историю, если она была удалена
                if currentStory?.id == storyId {
                    currentStory = nil
                }
                // Отправляем уведомление об удалении истории
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .storyDeleted, object: nil)
                }
                isLoading = false
                return true
            } else {
                errorMessage = response.message ?? "Failed to delete story"
                isLoading = false
                return false
            }
        } catch {
            handleStoryError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Helper Methods
    func clearCurrentStory() {
        currentStory = nil
    }
}
