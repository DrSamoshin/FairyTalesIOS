//
//  NetworkManager.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Observation

// MARK: - Network Results
enum NetworkResult<T> {
    case success(T)
    case failure(NetworkError)
}

// MARK: - Notification Names
extension Notification.Name {
    static let authenticationExpired = Notification.Name("authenticationExpired")
    static let storyDeleted = Notification.Name("storyDeleted")
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case apiError(ErrorResponse) // Стандартизированная ошибка API
    case internetConnection
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .apiError(let errorResponse):
            return errorResponse.message
        case .internetConnection:
            return "No internet connection"
        case .timeout:
            return "timeout_error_occurred".localized
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

@Observable
@MainActor
final class NetworkManager: Sendable {
    static let shared = NetworkManager()
    
    private let baseURL = "https://fairy-tales-api-134132058244.europe-west3.run.app"
    // private let baseURL = "http://192.168.1.215:8080"
    private let session: URLSession
    
    // Public access to base URL for streaming
    var streamingBaseURL: String { baseURL }
    
    var isLoading = false
    var lastError: NetworkError?
    
    private init() {
        print("NetworkManager: Initializing NetworkManager")
        print("NetworkManager: Base URL: \(baseURL)")

        
        // Конфигурация для продакшен сервера (HTTPS)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30  // Timeout для story generation
        config.timeoutIntervalForResource = 60 // Длительные операции
        
        print("NetworkManager: Configured timeouts - Request: 30s, Resource: 60s")
        
        // Используем кастомный delegate для надежной работы с HTTPS
        let delegate = CustomURLSessionDelegate()
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        
        print("NetworkManager: URLSession configured with custom delegate")
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        return try await performRequest(url: url, method: method, body: body, headers: headers, responseType: responseType)
    }
    
    private func performRequest<T: Codable>(
        url: URL,
        method: HTTPMethod,
        body: Data?,
        headers: [String: String],
        responseType: T.Type
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        isLoading = true
        
        do {
            print("NetworkManager: Making request to: \(request.url?.absoluteString ?? "unknown")")
            print("NetworkManager: Method: \(request.httpMethod ?? "unknown")")
            print("NetworkManager: Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                print("NetworkManager: Body: \(bodyString)")
            }
            
            print("NetworkManager: Sending URLSession request...")
            let (data, response) = try await session.data(for: request)
            print("NetworkManager: Received response from server")
            
            isLoading = false
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("NetworkManager: ERROR - Invalid HTTP response")
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            print("NetworkManager: Response status: \(httpResponse.statusCode)")
            print("NetworkManager: Response headers: \(httpResponse.allHeaderFields)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("NetworkManager: Response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401, 403:
                // Обработка ошибок авторизации - декодируем стандартный API ответ
                print("NetworkManager: Authentication error: \(httpResponse.statusCode)")
                
                // Отправляем уведомление для автоматического выхода
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .authenticationExpired, object: nil)
                }
                
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    print("NetworkManager: Successfully decoded API error: \(errorResponse.error_code ?? "NO_CODE")")
                    throw NetworkError.apiError(errorResponse)
                } else {
                    // Fallback для нестандартных ответов
                    print("NetworkManager: Failed to decode standard error response, using fallback")
                    let fallbackError = ErrorResponse(
                        success: false,
                        message: "Authentication failed",
                        errors: ["Authentication required"],
                        error_code: "AUTH_FAILED"
                    )
                    throw NetworkError.apiError(fallbackError)
                }
                
            case 400, 404...499:
                // Для остальных клиентских ошибок пытаемся декодировать стандартизированный ответ
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    print("Successfully decoded API error: \(errorResponse.error_code ?? "NO_CODE")")
                    throw NetworkError.apiError(errorResponse)
                } else {
                    // Fallback для нестандартных ответов
                    print("Failed to decode standard error response, using fallback")
                    let fallbackError = ErrorResponse(
                        success: false,
                        message: "Client error",
                        errors: ["Failed to decode server response"],
                        error_code: nil
                    )
                    throw NetworkError.apiError(fallbackError)
                }
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                return decodedResponse
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw NetworkError.decodingError
            }
            
        } catch {
            isLoading = false
            if let networkError = error as? NetworkError {
                lastError = networkError
            } else if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    lastError = NetworkError.internetConnection
                case .timedOut:
                    lastError = NetworkError.timeout
                case .appTransportSecurityRequiresSecureConnection:
                    print("NetworkManager: ATS Error: HTTP not allowed. Check Info.plist")
                    lastError = NetworkError.unknown(URLError(.appTransportSecurityRequiresSecureConnection))
                default:
                    lastError = NetworkError.unknown(urlError)
                }
            } else {
                lastError = NetworkError.unknown(error)
            }
            print("NetworkManager: Request failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Helper Methods
    func post<T: Codable, U: Codable>(
        endpoint: String,
        body: T,
        responseType: U.Type,
        headers: [String: String] = [:]
    ) async throws -> U {
        let bodyData = try JSONEncoder().encode(body)
        return try await request(
            endpoint: endpoint,
            method: .POST,
            body: bodyData,
            headers: headers,
            responseType: responseType
        )
    }
    
    func get<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        headers: [String: String] = [:]
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            responseType: responseType
        )
    }
    
    func delete<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        headers: [String: String] = [:]
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .DELETE,
            headers: headers,
            responseType: responseType
        )
    }
    
    // MARK: - Error Handling
    func clearError() {
        lastError = nil
    }
    
    // MARK: - Server Testing
    func testServerConnection() async {
        print("Testing server connection...")
        let testEndpoint = "/api/v1/health/app/"
        
        guard let url = URL(string: baseURL + testEndpoint) else {
            print("Invalid URL: \(baseURL + testEndpoint)")
            return
        }
        
        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("\(baseURL) - Response: \(httpResponse.statusCode)")
            } else {
                print("\(baseURL) - No HTTP response")
            }
        } catch {
            print("\(baseURL) - Error: \(error)")
        }
    }
    
    // MARK: - Legal Content Methods
    func getPrivacyPolicy() async throws -> PolicyResponse {
        return try await get(
            endpoint: "/api/v1/legal/policy-ios/",
            responseType: PolicyResponse.self
        )
    }
    
    func getTermsOfService() async throws -> TermsResponse {
        return try await get(
            endpoint: "/api/v1/legal/terms/",
            responseType: TermsResponse.self
        )
    }
    
    // MARK: - Health Check Methods
    func checkHealth() async throws -> HealthResponse {
        return try await get(
            endpoint: "/api/v1/health/app/",
            responseType: HealthResponse.self
        )
    }
}
