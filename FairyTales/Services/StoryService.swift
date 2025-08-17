//
//  StoryService.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Observation
import StoreKit

/// Universal service for story generation - supports both regular and streaming modes
@Observable
@MainActor
final class StoryService {
    static let shared = StoryService()
    
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    // MARK: - Published State
    var isLoading = false
    var errorMessage: String?
    var currentStory: Story?
    
    // MARK: - Streaming State
    var currentStreamingContent: String = ""
    var isStreaming: Bool = false
    var streamingProgress: String = ""
    var streamingStoryId: String?
    var isStreamingCompleted: Bool = false
    
    // MARK: - Typing Animation State
    private var bufferedContent: String = ""
    private var typingTimer: Timer?
    private var currentDisplayIndex: String.Index?
    
    // MARK: - Animation Configuration
    private struct TypingConfig {
        static let interval: TimeInterval = 0.03          // Интервал между обновлениями (30ms)
        static let charactersPerStep: Int = 2             // Символов за один шаг
        static let wordBasedDelay: Bool = true            // Пауза на пробелах и знаках препинания
        static let punctuationDelay: TimeInterval = 0.1  // Дополнительная задержка на знаках препинания
    }
    
    private var nextUpdateTime: TimeInterval = 0
    
    private init() {}
    
    // MARK: - Regular Story Generation
    func generateStory(request: StoryGenerateRequest) async -> Story? {
        clearError()
        isLoading = true
        
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
                print("Story generated successfully: \(story.title)")
                
                // Send notification for other parts of the app
                NotificationCenter.default.post(name: NSNotification.Name("StoryCreated"), object: nil)
                
                isLoading = false
                return story
            } else {
                errorMessage = response.message ?? "Failed to generate story"
                isLoading = false
                return nil
            }
        } catch {
            handleError(error)
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Streaming Story Generation
    func generateStoryStream(request: StoryGenerateRequest) {
        guard let token = tokenManager.accessToken else {
            errorMessage = "not_authenticated".localized
            return
        }
        
        guard let url = URL(string: "\(networkManager.streamingBaseURL)/api/v1/stories/generate-stream/") else {
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
                print("Fetched \(storiesData.stories.count) stories successfully")
                isLoading = false
                return storiesData.stories
            } else {
                errorMessage = response.message ?? "Failed to fetch stories"
                isLoading = false
                return []
            }
        } catch {
            handleError(error)
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
                print("Story deleted successfully")
                if currentStory?.id == storyId {
                    currentStory = nil
                }
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
            handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Streaming Control
    func cancelStreaming() {
        StoryStreamingService.shared.cancelGeneration()
        isStreaming = false
        streamingProgress = "generation_cancelled".localized
        stopTypingAnimation()
    }
    
    // MARK: - State Management
    private func resetStreamingState() {
        currentStreamingContent = ""
        errorMessage = nil
        streamingStoryId = nil
        isStreaming = true
        isStreamingCompleted = false
        streamingProgress = "connecting".localized
        
        // Сброс состояния анимации
        stopTypingAnimation()
        bufferedContent = ""
        currentDisplayIndex = nil
    }
    
    private func clearError() {
        errorMessage = nil
    }
    
    func clearCurrentStory() {
        currentStory = nil
    }
    
    func clearStreamingState() {
        currentStreamingContent = ""
        streamingStoryId = nil
        isStreaming = false
        isStreamingCompleted = false
        streamingProgress = ""
        
        // Сброс состояния анимации
        stopTypingAnimation()
        bufferedContent = ""
        currentDisplayIndex = nil
    }
    
    // MARK: - Helper Methods
    func createStoryRequest(
        storyName: String,
        heroName: String,
        storyIdea: String,
        storyStyle: String,
        language: String,
        age: Int,
        storyLength: Int,
        childGender: String
    ) -> StoryGenerateRequest {
        return StoryGenerateRequest(
            story_name: storyName,
            hero_name: heroName,
            story_idea: storyIdea,
            story_style: storyStyle,
            language: language,
            age: age,
            story_length: storyLength,
            child_gender: childGender
        )
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let errorResponse):
                print("Story API Error: \(errorResponse.error_code ?? "NO_CODE") - \(errorResponse.message)")
                
                if let errorCode = errorResponse.error_code,
                   let apiErrorCode = APIErrorCode(rawValue: errorCode) {
                    handleStandardAPIError(apiErrorCode, errorResponse: errorResponse)
                } else {
                    errorMessage = errorResponse.message
                }
                
            case .timeout:
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

// MARK: - StoryStreamingDelegate
extension StoryService: StoryStreamingDelegate {
    nonisolated func streamingDidStart(message: String) {
        Task { @MainActor in
            self.updateStreamingProgress(message)
        }
    }
    
    nonisolated func streamingDidReceiveContent(_ content: String) {
        Task { @MainActor in
            self.appendStreamingContent(content)
        }
    }
    
    nonisolated func streamingDidComplete(storyId: String?, message: String) {
        Task { @MainActor in
            self.completeStreaming(storyId: storyId, message: message)
        }
    }
    
    nonisolated func streamingDidFail(error: String) {
        Task { @MainActor in
            self.failStreaming(error: error)
        }
    }
    
    // MARK: - MainActor Helper Methods
    @MainActor
    private func updateStreamingProgress(_ message: String) {
        streamingProgress = message
    }
    
    @MainActor
    private func appendStreamingContent(_ content: String) {
        bufferedContent += content
        
        // Если таймер еще не запущен, запускаем печатание
        if typingTimer == nil {
            startTypingAnimation()
        }
        
        streamingProgress = "generating_story".localized
    }
    
    @MainActor
    private func completeStreaming(storyId: String?, message: String) {
        isStreaming = false
        if let id = storyId {
            streamingStoryId = id
        }
        streamingProgress = message
        
        // Send notification for other parts of the app
        NotificationCenter.default.post(name: NSNotification.Name("StoryCreated"), object: nil)
        
        // Проверяем, есть ли еще контент для отображения
        if let currentIndex = currentDisplayIndex, currentIndex >= bufferedContent.endIndex {
            // Весь контент уже отображен
            isStreamingCompleted = true
            stopTypingAnimation()
        } else {
            // Есть еще контент для отображения, продолжаем анимацию
            // isStreamingCompleted будет установлен в typeNextCharacters когда все будет готово
        }
    }
    
    @MainActor
    private func failStreaming(error: String) {
        isStreaming = false
        errorMessage = error
        streamingProgress = "error_prefix".localized + error
        stopTypingAnimation()
    }
    
    // MARK: - Typing Animation Methods
    @MainActor
    private func startTypingAnimation() {
        guard typingTimer == nil else { return }
        
        // Устанавливаем начальную позицию, если она не установлена
        if currentDisplayIndex == nil {
            currentDisplayIndex = currentStreamingContent.endIndex
        }
        
        nextUpdateTime = 0 // Сброс времени задержки
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: TypingConfig.interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.typeNextCharacters()
            }
        }
    }
    
    @MainActor
    private func stopTypingAnimation() {
        typingTimer?.invalidate()
        typingTimer = nil
    }
    
    @MainActor
    private func typeNextCharacters() {
        guard let currentIndex = currentDisplayIndex else { return }
        
        // Проверяем задержку
        let currentTime = Date().timeIntervalSince1970
        if currentTime < nextUpdateTime {
            return
        }
        
        let endIndex = bufferedContent.endIndex
        if currentIndex < endIndex {
            // Вычисляем новый индекс
            var newIndex = currentIndex
            var addedPunctuation = false
            
            for _ in 0..<TypingConfig.charactersPerStep {
                if newIndex < endIndex {
                    let char = bufferedContent[newIndex]
                    newIndex = bufferedContent.index(after: newIndex)
                    
                    // Проверяем на знаки препинания для дополнительной паузы
                    if TypingConfig.wordBasedDelay && (char == "." || char == "!" || char == "?" || char == "," || char == ";") {
                        addedPunctuation = true
                        break // Останавливаемся на знаке препинания
                    }
                } else {
                    break
                }
            }
            
            // Обновляем отображаемый контент
            currentStreamingContent = String(bufferedContent[..<newIndex])
            currentDisplayIndex = newIndex
            
            // Устанавливаем дополнительную задержку если нужно
            if addedPunctuation {
                nextUpdateTime = currentTime + TypingConfig.punctuationDelay
            }
            
        } else if !isStreaming {
            // Все символы отображены и стриминг завершен
            isStreamingCompleted = true
            stopTypingAnimation()
        }
    }
    
    // MARK: - Rating Helper
    @MainActor
    private func requestAppStoreRating() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: windowScene)
            } else {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}
