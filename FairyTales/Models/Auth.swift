//
//  Auth.swift
//  FairyTales
//
//  Created by AI Assistant.
//

import Foundation

// MARK: - Health Response
struct HealthResponse: Codable {
    let success: Bool
    let message: String?
    let data: HealthData?
    
    var isHealthy: Bool {
        return success && (data?.status?.lowercased() == "ok" || data?.status?.lowercased() == "healthy")
    }
}

struct HealthData: Codable {
    let status: String?
    let service: String?
    let timestamp: String?
    let version: String?
}
