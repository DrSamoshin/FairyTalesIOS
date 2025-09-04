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
//     private let baseURL = "http://10.192.16.50:8080"
    private let session: URLSession
    
    // Public access to base URL for streaming
    var streamingBaseURL: String { baseURL }
    
    var isLoading = false
    var lastError: NetworkError?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        let delegate = CustomURLSessionDelegate()
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
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
            print("❌ NetworkManager: Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        print("🌐 NetworkManager: Making \(method.rawValue) request to: \(url)")
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
            let (data, response) = try await session.data(for: request)
            
            isLoading = false
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ NetworkManager: Invalid response type")
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            print("📡 NetworkManager: Received response with status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401, 403:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .authenticationExpired, object: nil)
                }
                
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NetworkError.apiError(errorResponse)
                } else {
                    let fallbackError = ErrorResponse(
                        success: false,
                        message: "Authentication failed",
                        errors: ["Authentication required"],
                        error_code: "AUTH_FAILED"
                    )
                    throw NetworkError.apiError(fallbackError)
                }
                
            case 400, 404...499:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NetworkError.apiError(errorResponse)
                } else {
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
                return try JSONDecoder().decode(responseType, from: data)
            } catch {
                throw NetworkError.decodingError
            }
            
        } catch {
            isLoading = false
            print("❌ NetworkManager: Request failed with error: \(error)")
            
            if let networkError = error as? NetworkError {
                lastError = networkError
            } else if let urlError = error as? URLError {
                print("🔗 NetworkManager: URLError code: \(urlError.code.rawValue), description: \(urlError.localizedDescription)")
                switch urlError.code {
                case .notConnectedToInternet:
                    lastError = NetworkError.internetConnection
                case .timedOut:
                    lastError = NetworkError.timeout
                case .appTransportSecurityRequiresSecureConnection:
                    print("🔒 NetworkManager: ATS is blocking HTTP connection!")
                    lastError = NetworkError.unknown(URLError(.appTransportSecurityRequiresSecureConnection))
                default:
                    lastError = NetworkError.unknown(urlError)
                }
            } else {
                lastError = NetworkError.unknown(error)
            }
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
    
    func put<T: Codable, U: Codable>(
        endpoint: String,
        body: T,
        responseType: U.Type,
        headers: [String: String] = [:]
    ) async throws -> U {
        let bodyData = try JSONEncoder().encode(body)
        return try await request(
            endpoint: endpoint,
            method: .PUT,
            body: bodyData,
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
        let testEndpoint = "/api/v1/health/app/"
        
        guard let url = URL(string: baseURL + testEndpoint) else {
            return
        }
        
        do {
            let (_, _) = try await session.data(from: url)
        } catch {
            // Silent failure for testing
        }
    }
    
    // MARK: - Legal Content Methods
    func getPrivacyPolicy() async throws -> LegalContent {
        let htmlContent = try await getHTMLContent(endpoint: "/api/v1/legal/privacy-policy/")
        return LegalContent(content: htmlContent)
    }
    
    func getTermsOfService() async throws -> LegalContent {
        let htmlContent = try await getHTMLContent(endpoint: "/api/v1/legal/terms-of-use/")
        return LegalContent(content: htmlContent)
    }
    
    private func getHTMLContent(endpoint: String) async throws -> String {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        
        isLoading = true
        
        do {
            let (data, response) = try await session.data(for: request)
            isLoading = false
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401, 403:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .authenticationExpired, object: nil)
                }
                let fallbackError = ErrorResponse(
                    success: false,
                    message: "Authentication failed",
                    errors: ["Authentication required"],
                    error_code: "AUTH_FAILED"
                )
                throw NetworkError.apiError(fallbackError)
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            guard let htmlContent = String(data: data, encoding: .utf8) else {
                throw NetworkError.decodingError
            }
            
            return htmlContent
            
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
                default:
                    lastError = NetworkError.unknown(urlError)
                }
            } else {
                lastError = NetworkError.unknown(error)
            }
            throw error
        }
    }
    
    // MARK: - Health Check Methods
    func checkHealth() async throws -> HealthResponse {
        return try await get(
            endpoint: "/api/v1/health/app/",
            responseType: HealthResponse.self
        )
    }
}
