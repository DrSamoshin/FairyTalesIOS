//
//  AppTypography.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

// MARK: - Typography System
struct AppTypography {
    
    // MARK: - Size Constants
    private struct Sizes {
        static let h1: CGFloat = 36
        static let h2: CGFloat = 24
        static let h3: CGFloat = 20
        static let body: CGFloat = 18
        static let label: CGFloat = 16
        static let caption: CGFloat = 14
        static let small: CGFloat = 12
        static let icon: CGFloat = 24
        static let emoji: CGFloat = 40
    }
    
    // MARK: - Main Typography Styles
    
    /// H1 - Главные заголовки экранов (36pt, bold, rounded)
    static let h1 = Font.system(size: Sizes.h1, weight: .bold, design: .rounded)
    
    /// H2 - Подзаголовки, заголовки модалов (24pt, bold, rounded)
    static let h2 = Font.system(size: Sizes.h2, weight: .bold, design: .rounded)
    
    /// H3 - Большие кнопки, важные элементы (20pt, semibold, rounded)
    static let h3 = Font.system(size: Sizes.h3, weight: .semibold, design: .rounded)
    
    /// Body - Основной текст, контент историй (18pt, medium, rounded)
    static let body = Font.system(size: Sizes.body, weight: .medium, design: .rounded)
    
    /// Body Semibold - Основной текст с акцентом (18pt, semibold, rounded)
    static let bodySemibold = Font.system(size: Sizes.body, weight: .semibold, design: .rounded)
    
    /// Label - Лейблы форм, кнопки (16pt, semibold, rounded)
    static let label = Font.system(size: Sizes.label, weight: .semibold, design: .rounded)
    
    /// Label Medium - Обычные лейблы (16pt, medium, rounded)
    static let labelMedium = Font.system(size: Sizes.label, weight: .medium, design: .rounded)
    
    /// Caption - Описания, вторичный текст (14pt, medium, rounded)
    static let caption = Font.system(size: Sizes.caption, weight: .medium, design: .rounded)
    
    /// Caption Semibold - Акцентированные описания (14pt, semibold, rounded)
    static let captionSemibold = Font.system(size: Sizes.caption, weight: .semibold, design: .rounded)
    
    /// Small - Мелкий текст, даты (12pt, medium, rounded)
    static let small = Font.system(size: Sizes.small, weight: .medium, design: .rounded)
    
    /// Icon - Иконки (24pt, medium, rounded)
    static let icon = Font.system(size: Sizes.icon, weight: .medium, design: .rounded)
    
    /// Emoji - Emoji анимации (40pt, medium, rounded)
    static let emoji = Font.system(size: Sizes.emoji, weight: .medium, design: .rounded)
    
    // MARK: - Back Button Styles
    
    /// Back Button Icon - Иконка кнопки назад (16pt, semibold, default)
    static let backIcon = Font.system(size: Sizes.label, weight: .semibold)
    
    /// Back Button Text - Текст кнопки назад (16pt, semibold, rounded)
    static let backText = Font.system(size: Sizes.label, weight: .semibold, design: .rounded)
    
    // MARK: - Story Content Styles
    
    /// Story Title - Заголовок истории (36pt, bold, rounded)
    static let storyTitle = h1
    
    /// Story Content - Контент истории (18pt, regular, rounded)
    static let storyContent = Font.system(size: Sizes.body, weight: .regular, design: .rounded)
    
    /// Story Preview - Превью истории в карточке (15pt, regular, rounded) 
    static let storyPreview = Font.system(size: 15, weight: .regular, design: .rounded)
    
    // MARK: - Form Elements
    
    /// Input Field - Поля ввода (16pt, medium, rounded)
    static let inputField = labelMedium
    
    /// Picker Item - Элементы picker'а (14pt, medium, rounded)
    static let pickerItem = caption
    
    // MARK: - Legal Content
    
    /// Legal Title - Заголовки правовых документов (20pt, bold, rounded)
    static let legalTitle = Font.system(size: Sizes.h3, weight: .bold, design: .rounded)
    
    /// Legal Body - Текст правовых документов (16pt, medium, rounded)
    static let legalBody = labelMedium
    
    /// Legal Emoji - Emoji в правовых документах (48pt, medium, rounded)
    static let legalEmoji = Font.system(size: 48, weight: .medium, design: .rounded)
    
    // MARK: - Subtitle Styles
    
    /// Subtitle - Субтитры экранов (18pt, semibold, rounded)
    static let subtitle = bodySemibold
}

// MARK: - Font Extension
extension Font {
    
    // MARK: - App Typography Shortcuts
    
    /// H1 - Главные заголовки экранов
    static var appH1: Font { AppTypography.h1 }
    
    /// H2 - Подзаголовки, заголовки модалов
    static var appH2: Font { AppTypography.h2 }
    
    /// H3 - Большие кнопки, важные элементы
    static var appH3: Font { AppTypography.h3 }
    
    /// Body - Основной текст
    static var appBody: Font { AppTypography.body }
    
    /// Body Semibold - Основной текст с акцентом
    static var appBodySemibold: Font { AppTypography.bodySemibold }
    
    /// Label - Лейблы форм, кнопки
    static var appLabel: Font { AppTypography.label }
    
    /// Label Medium - Обычные лейблы
    static var appLabelMedium: Font { AppTypography.labelMedium }
    
    /// Caption - Описания, вторичный текст
    static var appCaption: Font { AppTypography.caption }
    
    /// Caption Semibold - Акцентированные описания
    static var appCaptionSemibold: Font { AppTypography.captionSemibold }
    
    /// Small - Мелкий текст, даты
    static var appSmall: Font { AppTypography.small }
    
    /// Icon - Иконки
    static var appIcon: Font { AppTypography.icon }
    
    /// Emoji - Emoji анимации
    static var appEmoji: Font { AppTypography.emoji }
    
    /// Back Button Icon - Иконка кнопки назад
    static var appBackIcon: Font { AppTypography.backIcon }
    
    /// Back Button Text - Текст кнопки назад
    static var appBackText: Font { AppTypography.backText }
    
    /// Story Title - Заголовок истории
    static var appStoryTitle: Font { AppTypography.storyTitle }
    
    /// Story Content - Контент истории
    static var appStoryContent: Font { AppTypography.storyContent }
    
    /// Story Preview - Превью истории в карточке
    static var appStoryPreview: Font { AppTypography.storyPreview }
    
    /// Input Field - Поля ввода
    static var appInputField: Font { AppTypography.inputField }
    
    /// Picker Item - Элементы picker'а
    static var appPickerItem: Font { AppTypography.pickerItem }
    
    /// Legal Title - Заголовки правовых документов
    static var appLegalTitle: Font { AppTypography.legalTitle }
    
    /// Legal Body - Текст правовых документов
    static var appLegalBody: Font { AppTypography.legalBody }
    
    /// Legal Emoji - Emoji в правовых документах
    static var appLegalEmoji: Font { AppTypography.legalEmoji }
    
    /// Subtitle - Субтитры экранов
    static var appSubtitle: Font { AppTypography.subtitle }
}
