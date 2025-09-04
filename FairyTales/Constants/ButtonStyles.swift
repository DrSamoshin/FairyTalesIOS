//
//  ButtonStyles.swift
//  FairyTales
//
//  Created by Assistant on 26/08/2025.
//

import SwiftUI

// MARK: - Button Style Constants
struct ButtonStyles {
    
    // MARK: - Layout Constants
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let itemHeight: CGFloat = 56
        static let itemPadding: CGFloat = 20
        static let itemSpacing: CGFloat = 12
        static let iconFrameWidth: CGFloat = 28
        static let borderWidth: CGFloat = 2
        static let shadowRadius: CGFloat = 8
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)
    }
    
    // MARK: - Button Configuration
    struct ButtonConfig {
        let background: LinearGradient
        let border: Color
        let icon: String
        
        // MARK: - Predefined Configurations
        
        /// Lime Green gradient button
        static let limeGreen = ButtonConfig(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.4),
                    Color(red: 0.1, green: 0.6, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            border: Color(red: 0.4, green: 0.9, blue: 0.5),
            icon: "crown.fill"
        )
        
        /// Sky Blue gradient button
        static let skyBlue = ButtonConfig(
            background: AppColors.contrastSecondary,
            border: Color(red: 0.7, green: 0.9, blue: 0.9),
            icon: "globe"
        )
        
        /// Lavender Purple gradient button
        static let lavenderPurple = ButtonConfig(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.5, blue: 0.8),
                    Color(red: 0.6, green: 0.3, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            border: Color(red: 0.9, green: 0.7, blue: 0.9),
            icon: "doc.text"
        )
        
        /// Sunset Orange gradient button
        static let sunsetOrange = ButtonConfig(
            background: AppColors.orangeGradient,
            border: Color(red: 1.0, green: 0.9, blue: 0.7),
            icon: "doc.plaintext"
        )
        
        /// Cherry Red gradient button
        static let cherryRed = ButtonConfig(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.35, blue: 0.35),
                    Color(red: 0.65, green: 0.25, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            border: Color(red: 1.0, green: 0.6, blue: 0.6),
            icon: "rectangle.portrait.and.arrow.right"
        )
        
        /// Forest Green gradient button
        static let forestGreen = ButtonConfig(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.3),
                    Color(red: 0.7, green: 1.0, blue: 0.85)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            border: Color(red: 0.3, green: 0.6, blue: 0.4),
            icon: "person.3.fill"
        )
        
        /// Peach Cream gradient button  
        static let peachCream = ButtonConfig(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.7),
                    Color(red: 1.0, green: 0.95, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            border: Color(red: 1.0, green: 0.98, blue: 0.85),
            icon: "book.fill"
        )
        
        /// Dark Red gradient button for delete account
        static let darkRed = ButtonConfig(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.7, green: 0.2, blue: 0.2),
                    Color(red: 0.65, green: 0.25, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            border: Color(red: 0.9, green: 0.4, blue: 0.4),
            icon: "trash.fill"
        )
        
        // MARK: - Legacy Aliases for backward compatibility
        static let subscription = limeGreen
        static let language = skyBlue
        static let privacy = lavenderPurple
        static let terms = sunsetOrange
        static let logout = cherryRed
        static let heroes = forestGreen
        static let stories = peachCream
        static let deleteAccount = darkRed
    }
}

// MARK: - Reusable Button Components
extension View {
    
    /// Create a styled button card with gradient background and border
    func styledButtonCard(
        config: ButtonStyles.ButtonConfig,
        height: CGFloat = ButtonStyles.Layout.itemHeight
    ) -> some View {
        self
            .padding(ButtonStyles.Layout.itemPadding)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(config.background)
            .cornerRadius(ButtonStyles.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ButtonStyles.Layout.cornerRadius)
                    .stroke(config.border, lineWidth: ButtonStyles.Layout.borderWidth)
            )
            .shadow(
                color: AppColors.softShadow,
                radius: ButtonStyles.Layout.shadowRadius,
                x: ButtonStyles.Layout.shadowOffset.width,
                y: ButtonStyles.Layout.shadowOffset.height
            )
    }
    
    /// Create a standard button icon
    func styledButtonIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.appIcon)
            .foregroundColor(.white)
            .frame(width: ButtonStyles.Layout.iconFrameWidth)
    }
    
    /// Create a chevron icon for navigation buttons
    var styledChevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.appIcon)
            .foregroundColor(.white.opacity(0.7))
    }
}