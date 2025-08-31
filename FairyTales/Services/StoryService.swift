//
//  StoryService.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Observation
import StoreKit

/// Service for story generation and management with streaming support
@Observable
@MainActor
final class StoryService {
    static let shared = StoryService()
    
    // MARK: - Dependencies
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    // MARK: - Public State
    var isLoading = false
    var errorMessage: String?
    var currentStory: Story?
    var stories: [Story] = []
    
    // MARK: - Streaming State
    var currentStreamingContent: String = ""
    var isStreaming: Bool = false
    var streamingProgress: String = ""
    var streamingStoryId: String?
    var isStreamingCompleted: Bool = false
    var isTypingCompleted: Bool = false
    
    // MARK: - Private State
    private var bufferedContent: String = ""
    private var typingTimer: Timer?
    private var currentDisplayIndex: String.Index?
    private var nextUpdateTime: TimeInterval = 0
    
    // MARK: - Configuration
    private struct Config {
        static let typingInterval: TimeInterval = 0.03
        static let charactersPerStep: Int = 2
        static let punctuationDelay: TimeInterval = 0.1
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Generate story with streaming response
    func generateStoryStream(request: StoryGenerateRequest) {
        guard let token = tokenManager.accessToken else {
            errorMessage = "not_authenticated".localized
            return
        }
        
        guard let url = URL(string: "\(networkManager.streamingBaseURL)/api/v1/stories/generate-with-heroes-stream/") else {
            errorMessage = "invalid_url".localized
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            errorMessage = "encoding_error".localized
            return
        }
        
        resetStreamingState()
        
        let streamingService = StoryStreamingService()
        streamingService.delegate = self
        streamingService.startStreaming(with: urlRequest)
    }
    
    /// Fetch a specific story by ID
    func fetchStory(storyId: String) async -> Story? {
        clearError()
        isLoading = true
        
        do {
            let headers = tokenManager.authHeaders
            let response: StoryResponse = try await networkManager.get(
                endpoint: "/api/v1/stories/\(storyId)/",
                responseType: StoryResponse.self,
                headers: headers
            )
            
            isLoading = false
            
            if response.success, let storyData = response.data {
                return storyData.story
            } else {
                errorMessage = response.message ?? "Failed to fetch story"
                return nil
            }
        } catch {
            isLoading = false
            handleError(error)
            return nil
        }
    }
    
    /// Fetch user's stories
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
            
            isLoading = false
            
            if response.success, let storiesData = response.data {
                stories = storiesData.stories
                return storiesData.stories
            } else {
                errorMessage = response.message ?? "Failed to fetch stories"
                return []
            }
        } catch {
            handleError(error)
            isLoading = false
            return []
        }
    }
    
    /// Delete a story
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
            
            isLoading = false
            
            if response.success {
                NotificationCenter.default.post(name: NSNotification.Name("StoryDeleted"), object: nil)
                return true
            } else {
                errorMessage = response.message ?? "Failed to delete story"
                return false
            }
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Create story request
    func createStoryRequest(
        storyName: String,
        storyIdea: String,
        storyStyle: String,
        language: String,
        storyLength: Int,
        selectedHeroes: [Hero]
    ) -> StoryGenerateRequest {
        return StoryGenerateRequest(
            story_name: storyName,
            story_idea: storyIdea,
            story_style: storyStyle,
            language: language,
            story_length: storyLength,
            heroes: selectedHeroes
        )
    }
}

// MARK: - Private Methods
private extension StoryService {
    
    func clearError() {
        errorMessage = nil
    }
    
    func resetStreamingState() {
        isStreaming = true
        currentStreamingContent = ""
        bufferedContent = ""
        streamingProgress = ""
        streamingStoryId = nil
        isStreamingCompleted = false
        isTypingCompleted = false
        typingTimer?.invalidate()
        typingTimer = nil
        currentDisplayIndex = nil
    }
    
    func startTypingAnimation() {
        guard currentDisplayIndex == nil else { return }
        currentDisplayIndex = bufferedContent.startIndex
        nextUpdateTime = CACurrentMediaTime()
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: Config.typingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTypingAnimation()
            }
        }
    }
    
    func updateTypingAnimation() {
        let currentTime = CACurrentMediaTime()
        guard currentTime >= nextUpdateTime else { return }
        
        guard let currentIndex = currentDisplayIndex,
              currentIndex < bufferedContent.endIndex else {
            if isStreamingCompleted {
                completeTypingAnimation()
            }
            return
        }
        
        let endIndex = min(
            bufferedContent.index(currentIndex, offsetBy: Config.charactersPerStep, limitedBy: bufferedContent.endIndex) ?? bufferedContent.endIndex,
            bufferedContent.endIndex
        )
        
        let newContent = String(bufferedContent[..<endIndex])
        currentStreamingContent = newContent
        currentDisplayIndex = endIndex
        
        let lastChar = bufferedContent[bufferedContent.index(before: endIndex)]
        if ".,!?;:".contains(lastChar) {
            nextUpdateTime = currentTime + Config.punctuationDelay
        } else {
            nextUpdateTime = currentTime + Config.typingInterval
        }
        
        if endIndex >= bufferedContent.endIndex && isStreamingCompleted {
            completeTypingAnimation()
        }
    }
    
    func completeTypingAnimation() {
        typingTimer?.invalidate()
        typingTimer = nil
        currentStreamingContent = bufferedContent
        currentDisplayIndex = nil
        isTypingCompleted = true
    }
    
    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let errorResponse):
                if let errorCode = errorResponse.error_code,
                   let apiErrorCode = APIErrorCode(rawValue: errorCode) {
                    handleStandardAPIError(apiErrorCode, errorResponse: errorResponse)
                } else {
                    errorMessage = errorResponse.message
                }
            case .timeout:
                errorMessage = "Request timeout. Please try again."
            case .serverError(500):
                errorMessage = "server_error_suggestion".localized
            case .serverError(let code):
                errorMessage = "Server error (\(code)). Please try again later."
            default:
                errorMessage = networkError.errorDescription
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    func handleStandardAPIError(_ errorCode: APIErrorCode, errorResponse: ErrorResponse) {
        switch errorCode {
        case .tokenExpired:
            errorMessage = "Please login again"
        case .validationError:
            errorMessage = errorResponse.errors.joined(separator: "\n")
        case .internalError, .serviceUnavailable:
            errorMessage = "server_error_suggestion".localized
        default:
            errorMessage = errorResponse.message
        }
    }
}

// MARK: - StoryStreamingDelegate
extension StoryService: StoryStreamingDelegate {
    
    nonisolated func streamingDidStart(message: String) {
        Task { @MainActor in
            streamingProgress = message
        }
    }
    
    nonisolated func streamingDidReceiveContent(_ content: String) {
        Task { @MainActor in
            bufferedContent += content
            
            if typingTimer == nil {
                startTypingAnimation()
            }
            
            streamingProgress = "generating_story".localized
        }
    }
    
    nonisolated func streamingDidComplete(storyId: String?, message: String) {
        Task { @MainActor in
            isStreaming = false
            if let id = storyId {
                streamingStoryId = id
            }
            streamingProgress = message
            
            NotificationCenter.default.post(name: NSNotification.Name("StoryCreated"), object: nil)
            
            if let currentIndex = currentDisplayIndex, currentIndex >= bufferedContent.endIndex {
                completeTypingAnimation()
            } else {
                isStreamingCompleted = true
            }
        }
    }
    
    nonisolated func streamingDidFail(error: String) {
        Task { @MainActor in
            isStreaming = false
            errorMessage = error
            typingTimer?.invalidate()
            typingTimer = nil
            currentDisplayIndex = nil
        }
    }
}