//
//  LegalContentScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 15/08/2025.
//

import SwiftUI
import WebKit

struct LegalContentScreen: View {
    let contentType: LegalContentType
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var legalManager = LegalManager.shared
    @Environment(\.dismiss) private var dismiss
    
    enum LegalContentType {
        case privacyPolicy
        case termsOfService
        
        var title: String {
            switch self {
            case .privacyPolicy:
                return "privacy_policy".localized
            case .termsOfService:
                return "terms_of_service".localized
            }
        }
        
        var navigationTitle: String {
            switch self {
            case .privacyPolicy:
                return "privacy_policy_title".localized
            case .termsOfService:
                return "terms_title".localized
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.softWhite
                    .ignoresSafeArea()
                
                if legalManager.isLoading {
                    loadingView
                } else if let errorMessage = legalManager.errorMessage {
                    errorView(errorMessage)
                } else {
                    contentView
                }
            }
            .navigationTitle(contentType.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.fairyBlue)
                    .font(.appLabelMedium)
                }
            }
        }
        .task {
            await loadContent()
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let content = getCurrentContent() {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(content.title)
                            .font(.appH2)
                            .foregroundColor(AppColors.darkText)
                        
                        HStack {
                            Text("version".localized + " \(content.version)")
                                .font(.appCaption)
                                .foregroundColor(AppColors.subtleText)
                            
                            Spacer()
                            
                            Text("last_updated".localized + " \(formatDate(content.effectiveDate))")
                                .font(.appCaption)
                                .foregroundColor(AppColors.subtleText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Content
                    MarkdownWebView(markdownContent: content.content)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 600) // Минимальная высота для отображения
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                } else {
                    emptyContentView
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.fairyPurple)
            
            Text("loading".localized)
                .font(.appLegalBody)
                .foregroundColor(AppColors.subtleText)
        }
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.appLegalEmoji)
                .foregroundColor(AppColors.fairyPink)
            
            Text("error_occurred".localized)
                .font(.appLegalTitle)
                .foregroundColor(AppColors.darkText)
            
            Text(message)
                .font(.appLegalBody)
                .foregroundColor(AppColors.darkText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("try_again".localized) {
                Task {
                    await loadContent()
                }
            }
            .font(.appLegalBody)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.contrastPrimary)
            .cornerRadius(25)
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Empty Content View
    private var emptyContentView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.appLegalEmoji)
                .foregroundColor(AppColors.subtleText)
            
            Text("no_content_available".localized)
                .font(.appLegalTitle)
                .foregroundColor(AppColors.darkText)
            
            Text("content_not_loaded".localized)
                .font(.appLegalBody)
                .foregroundColor(AppColors.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
    
    // MARK: - WebView for Markdown
    
    // MARK: - Helper Methods
    private func getCurrentContent() -> LegalContent? {
        switch contentType {
        case .privacyPolicy:
            return legalManager.privacyPolicy
        case .termsOfService:
            return legalManager.termsOfService
        }
    }
    
    private func loadContent() async {
        switch contentType {
        case .privacyPolicy:
            if !legalManager.hasPrivacyPolicy() {
                await legalManager.loadPrivacyPolicy()
            }
        case .termsOfService:
            if !legalManager.hasTermsOfService() {
                await legalManager.loadTermsOfService()
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Пробуем сначала стандартный ISO8601 формат
        let isoDate = DateFormatter.parseUTCDate(from: dateString)
        if isoDate != Date() || dateString.contains("T") { // Если успешно распарсили или это ISO формат
            return DateFormatter.formatLocalDate(isoDate, style: .medium)
        }
        
        // Fallback для формата только даты (yyyy-MM-dd)
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        simpleDateFormatter.timeZone = TimeZone.current
        
        if let date = simpleDateFormatter.date(from: dateString) {
            return DateFormatter.formatLocalDate(date, style: .medium)
        }
        
        return dateString.isEmpty ? "N/A" : dateString
    }
}

// MARK: - WebView Component
struct MarkdownWebView: UIViewRepresentable {
    let markdownContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = true // Allow WebView scrolling
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlContent = convertMarkdownToHTML(markdownContent)
        print("Loading HTML content with length: \(htmlContent.count)")
        print("Markdown content preview: \(String(markdownContent.prefix(100)))...")
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    private func convertMarkdownToHTML(_ markdown: String) -> String {
        let styledHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: #333333;
                    background-color: transparent;
                    margin: 0;
                    padding: 20px;
                    overflow-x: hidden;
                }
                
                h1 {
                    font-size: 24px;
                    font-weight: bold;
                    color: #333333;
                    margin: 24px 0 16px 0;
                    line-height: 1.3;
                }
                
                h2 {
                    font-size: 20px;
                    font-weight: 600;
                    color: #333333;
                    margin: 20px 0 12px 0;
                    line-height: 1.4;
                }
                
                h3 {
                    font-size: 18px;
                    font-weight: 500;
                    color: #333333;
                    margin: 16px 0 8px 0;
                }
                
                p {
                    margin: 12px 0;
                    text-align: left;
                }
                
                ul {
                    margin: 12px 0;
                    padding-left: 20px;
                }
                
                li {
                    margin: 6px 0;
                }
                
                strong {
                    font-weight: 600;
                    color: #333333;
                }
                
                em {
                    font-style: italic;
                }
                
                code {
                    background-color: #f5f5f5;
                    padding: 2px 4px;
                    border-radius: 3px;
                    font-family: Monaco, Consolas, monospace;
                    font-size: 14px;
                }
            </style>
        </head>
        <body>
            \(simpleMarkdownToHTML(markdown))
        </body>
        </html>
        """
        return styledHTML
    }
    
    private func simpleMarkdownToHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        var processedLines: [String] = []
        var inList = false
        
        print("Processing \(lines.count) lines of markdown")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                if inList {
                    processedLines.append("</ul>")
                    inList = false
                }
                processedLines.append("")
            } else if trimmedLine.hasPrefix("# ") {
                if inList {
                    processedLines.append("</ul>")
                    inList = false
                }
                let title = String(trimmedLine.dropFirst(2))
                processedLines.append("<h1>\(title)</h1>")
            } else if trimmedLine.hasPrefix("## ") {
                if inList {
                    processedLines.append("</ul>")
                    inList = false
                }
                let title = String(trimmedLine.dropFirst(3))
                processedLines.append("<h2>\(title)</h2>")
            } else if trimmedLine.hasPrefix("### ") {
                if inList {
                    processedLines.append("</ul>")
                    inList = false
                }
                let title = String(trimmedLine.dropFirst(4))
                processedLines.append("<h3>\(title)</h3>")
            } else if trimmedLine.hasPrefix("- ") {
                if !inList {
                    processedLines.append("<ul>")
                    inList = true
                }
                let item = String(trimmedLine.dropFirst(2))
                let boldText = item.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
                processedLines.append("<li>\(boldText)</li>")
            } else {
                if inList {
                    processedLines.append("</ul>")
                    inList = false
                }
                let boldText = trimmedLine.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
                processedLines.append("<p>\(boldText)</p>")
            }
        }
        
        // Close list if still open
        if inList {
            processedLines.append("</ul>")
        }
        
        let result = processedLines.joined(separator: "\n")
        print("Generated HTML with \(result.count) characters")
        return result
    }
}
