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
    
    // Extracted properties from HTML content
    var title: String {
        // Extract title from HTML content using regex
        let titlePattern = "<h1[^>]*>([^<]+)</h1>"
        if let regex = try? NSRegularExpression(pattern: titlePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            let htmlTitle = String(content[range])
            // Remove any remaining HTML tags and decode HTML entities
            return htmlTitle.replacingOccurrences(of: "&amp;", with: "&")
                           .replacingOccurrences(of: "&lt;", with: "<")
                           .replacingOccurrences(of: "&gt;", with: ">")
                           .replacingOccurrences(of: "&quot;", with: "\"")
                           .trimmingCharacters(in: .whitespaces)
        }
        return "Legal Document"
    }
    
    var effectiveDate: String {
        // Extract effective date from HTML content
        let effectiveDatePatterns = [
            "Effective[\\s]*[Dd]ate[:\\s]*([0-9]{1,2}[\\s]*[A-Za-z]+[\\s]*[0-9]{4})",
            "Effective[\\s]*[Dd]ate[:\\s]*([0-9]{4}-[0-9]{2}-[0-9]{2})",
            "Last[\\s]*[Uu]pdated[:\\s]*([0-9]{1,2}[\\s]*[A-Za-z]+[\\s]*[0-9]{4})",
            "Last[\\s]*[Uu]pdated[:\\s]*([0-9]{4}-[0-9]{2}-[0-9]{2})"
        ]
        
        for pattern in effectiveDatePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
               let range = Range(match.range(at: 1), in: content) {
                return String(content[range]).trimmingCharacters(in: .whitespaces)
            }
        }
        return ""
    }
    
    var version: String {
        // Try to extract version from HTML content
        let versionPattern = "[Vv]ersion[:\\s]*([0-9]+\\.[0-9]+)"
        if let regex = try? NSRegularExpression(pattern: versionPattern),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        return "1.0" // Default version
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
