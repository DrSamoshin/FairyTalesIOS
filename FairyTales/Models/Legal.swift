//
//  Legal.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 15/08/2025.
//

import Foundation

// MARK: - Legal Content Models
struct LegalContent: Codable {
    let content: String
    
    // Extracted properties from content
    var title: String {
        // Extract title from markdown content
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("# ") {
                return String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            }
        }
        return "Legal Document"
    }
    
    var effectiveDate: String {
        // Extract effective date from content
        let pattern = "\\*\\*Effective date:\\*\\* ([0-9]{4}-[0-9]{2}-[0-9]{2})"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        return ""
    }
    
    var version: String {
        return "1.0" // Default version since not provided by server
    }
}

// MARK: - API Response Models
struct PolicyData: Codable {
    let policy: String
}

struct PolicyResponse: Codable {
    let success: Bool
    let data: PolicyData
    let message: String?
    
    var legalContent: LegalContent {
        return LegalContent(content: data.policy)
    }
    
    var endpoint: String {
        return "/api/v1/legal/policy-ios/"
    }
}

struct TermsData: Codable {
    let terms: String
}

struct TermsResponse: Codable {
    let success: Bool
    let data: TermsData
    let message: String?
    
    var legalContent: LegalContent {
        return LegalContent(content: data.terms)
    }
    
    var endpoint: String {
        return "/api/v1/legal/terms/"
    }
}
