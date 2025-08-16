//
//  StoryStreamingService.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Combine

// MARK: - Streaming Delegate Protocol
protocol StoryStreamingDelegate: AnyObject {
    nonisolated func streamingDidStart(message: String)
    nonisolated func streamingDidReceiveContent(_ content: String)
    nonisolated func streamingDidComplete(storyId: String?, message: String)
    nonisolated func streamingDidFail(error: String)
}

@MainActor
final class StoryStreamingService: NSObject, ObservableObject {
    static let shared = StoryStreamingService()
    
    weak var delegate: StoryStreamingDelegate?
    // MARK: - Published Properties
    @Published var currentStory: String = ""
    @Published var isGenerating: Bool = false
    @Published var error: String?
    @Published var storyId: String?
    @Published var generationProgress: String = ""
    @Published var isCompleted: Bool = false
    
    // MARK: - Private Properties
    private var urlSessionTask: URLSessionDataTask?
    private var urlSession: URLSession
    private let bufferQueue = DispatchQueue(label: "buffer.queue")
    private nonisolated(unsafe) var _buffer: String = ""
    private nonisolated(unsafe) var _lastUpdateTime: TimeInterval = 0
    private let networkManager = NetworkManager.shared
    private let tokenManager = TokenManager.shared
    
    override init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300 // 5 minutes
        config.timeoutIntervalForResource = 600 // 10 minutes
        self.urlSession = URLSession(configuration: config)
        super.init()
        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Public Methods
    func startStreaming(with request: URLRequest) {
        resetState()
        urlSessionTask = urlSession.dataTask(with: request)
        urlSessionTask?.resume()
    }
    
    func generateStoryStream(storyData: StoryGenerate) {
        guard let token = tokenManager.accessToken else {
            error = "not_authenticated".localized
            return
        }
        
        guard let url = URL(string: "\(networkManager.streamingBaseURL)/api/v1/stories/generate-stream/") else {
            error = "invalid_url".localized
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        do {
            request.httpBody = try JSONEncoder().encode(storyData)
        } catch {
            self.error = "encoding_error".localized
            return
        }
        
        resetState()
        
        urlSessionTask = urlSession.dataTask(with: request)
        urlSessionTask?.resume()
    }
    
    func cancelGeneration() {
        urlSessionTask?.cancel()
        urlSessionTask = nil
        Task { @MainActor in
            self.isGenerating = false
            self.generationProgress = "generation_cancelled".localized
        }
    }
    
    // MARK: - Private Methods
    private func resetState() {
        Task { @MainActor in
            self.currentStory = ""
            self.error = nil
            self.storyId = nil
            self.isGenerating = true
            self.isCompleted = false
            self.generationProgress = "connecting".localized
        }
        
        bufferQueue.sync {
            _buffer = ""
        }
    }
    
    private nonisolated func processSSEData(_ data: String) {
        let lines = bufferQueue.sync { () -> [String] in
            _buffer += data
            let lines = _buffer.components(separatedBy: .newlines)
            
            // Keep the last incomplete line in buffer
            if let lastLine = lines.last, !lastLine.isEmpty {
                _buffer = lastLine
                return Array(lines.dropLast())
            } else {
                _buffer = ""
                return Array(lines.dropLast())
            }
        }
        
        // Process complete lines
        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6)) // Remove "data: "
                parseSSEMessage(jsonString)
            }
        }
    }
    
    private nonisolated func parseSSEMessage(_ jsonString: String) {
        guard !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else { return }
        
        do {
            if let message = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let typeString = message["type"] as? String,
               let messageType = SSEMessageType(rawValue: typeString) {
                
                Task { @MainActor in
                    self.handleSSEMessage(type: messageType, data: message)
                }
            }
        } catch {
            print("Failed to parse SSE message: \(error)")
        }
    }
    
    private func handleSSEMessage(type: SSEMessageType, data: [String: Any]) {
        switch type {
        case .started:
            if let message = data["message"] as? String {
                generationProgress = message
                delegate?.streamingDidStart(message: message)
                print("Generation started: \(message)")
            }
            
        case .content:
            if let content = data["data"] as? String {
                currentStory += content
                delegate?.streamingDidReceiveContent(content)
                
                // Throttle progress updates to avoid too frequent UI updates
                let currentTime = Date().timeIntervalSince1970
                if currentTime - _lastUpdateTime > 0.1 { // Update progress max once per 100ms
                    _lastUpdateTime = currentTime
                    generationProgress = "generating_story".localized
                }
            }
            
        case .completed:
            isGenerating = false
            isCompleted = true
            if let storyIdStr = data["story_id"] as? String {
                storyId = storyIdStr
            }
            if let message = data["message"] as? String {
                generationProgress = message
                delegate?.streamingDidComplete(storyId: storyId, message: message)
                print("Generation completed: \(message)")
            }
            if let length = data["story_length"] as? Int {
                generationProgress += " (\(length) characters)"
            }
            
        case .error:
            isGenerating = false
            if let errorMessage = data["message"] as? String {
                error = errorMessage
                delegate?.streamingDidFail(error: errorMessage)
                generationProgress = "error_prefix".localized + errorMessage
            }
        }
    }
    
    // MARK: - Application Lifecycle Handling
    func handleAppDidEnterBackground() {
        // Don't cancel the generation, just suspend the task
        urlSessionTask?.suspend()
    }
    
    func handleAppWillEnterForeground() {
        // Resume the task if it was suspended
        if isGenerating, let task = urlSessionTask {
            task.resume()
        }
    }
    
    func handleAppWillTerminate() {
        // Save current story state if possible
        if !currentStory.isEmpty && storyId == nil {
            // Save to local storage for recovery
            UserDefaults.standard.set(currentStory, forKey: "lastGeneratedStory")
            UserDefaults.standard.set(Date(), forKey: "lastGenerationTime")
        }
        
        cancelGeneration()
    }
    
    // MARK: - Recovery Methods
    func recoverLastStory() -> String? {
        guard let lastStory = UserDefaults.standard.string(forKey: "lastGeneratedStory"),
              let lastTime = UserDefaults.standard.object(forKey: "lastGenerationTime") as? Date,
              Date().timeIntervalSince(lastTime) < 3600 else { // 1 hour
            return nil
        }
        
        // Clear the saved story after recovery
        UserDefaults.standard.removeObject(forKey: "lastGeneratedStory")
        UserDefaults.standard.removeObject(forKey: "lastGenerationTime")
        
        return lastStory
    }
}

// MARK: - URLSessionDataDelegate
extension StoryStreamingService: URLSessionDataDelegate {
    nonisolated func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Task { @MainActor in
                self.error = "invalid_response".localized
                self.isGenerating = false
            }
            completionHandler(.cancel)
            return
        }
        
        if httpResponse.statusCode != 200 {
            Task { @MainActor in
                self.error = "server_error_code".localized + " (\(httpResponse.statusCode))"
                self.isGenerating = false
            }
            completionHandler(.cancel)
            return
        }
        
        completionHandler(.allow)
    }
    
    nonisolated func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
        processSSEData(string)
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task { @MainActor in
            self.isGenerating = false
            
            if let error = error {
                let nsError = error as NSError
                
                // Handle cancellation differently from actual errors
                if nsError.code == NSURLErrorCancelled {
                    self.generationProgress = "generation_cancelled".localized
                } else {
                    self.error = error.localizedDescription
                    self.generationProgress = "connection_error".localized
                }
            } else if self.storyId == nil && self.error == nil {
                // Stream ended without completion message
                self.generationProgress = "generation_completed_connection_closed".localized
            }
        }
    }
}
