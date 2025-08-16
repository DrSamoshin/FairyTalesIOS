//
//  DateFormatter+UTC.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation

// MARK: - DateFormatter Extensions
extension DateFormatter {
    /// Парсит UTC дату из строки и возвращает Date для отображения в локальном часовом поясе
    static func parseUTCDate(from dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC") // Явно указываем, что входящие данные в UTC
        
        guard let utcDate = formatter.date(from: dateString) else {
            return Date() // Fallback на текущую дату
        }
        
        // Дата автоматически будет отображаться в локальном часовом поясе
        // когда используется Text(..., style: .date) или другие SwiftUI форматтеры
        return utcDate
    }
    
    /// Форматирует дату для отображения в локальном часовом поясе
    static func formatLocalDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeZone = TimeZone.current // Используем текущий часовой пояс
        return formatter.string(from: date)
    }
    
    /// Форматирует дату и время для отображения в локальном часовом поясе
    static func formatLocalDateTime(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.timeZone = TimeZone.current // Используем текущий часовой пояс
        return formatter.string(from: date)
    }
    
    /// Относительное время (например: "2 часа назад", "вчера")
    static func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
