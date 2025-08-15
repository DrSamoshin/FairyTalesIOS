//
//  AppColors.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct AppColors {
    
    // MARK: - Primary Colors
    static let fairyPurple = Color(red: 0.6, green: 0.4, blue: 0.8)
    static let fairyPink = Color(red: 0.9, green: 0.6, blue: 0.8)
    static let fairyBlue = Color(red: 0.5, green: 0.7, blue: 0.9)
    static let fairyGold = Color(red: 1.0, green: 0.8, blue: 0.4)
    static let fairyMint = Color(red: 0.6, green: 0.9, blue: 0.8)
    static let fairyLavender = Color(red: 0.8, green: 0.7, blue: 0.9)
    
    // MARK: - Background Colors
    static let softWhite = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let cloudWhite = Color(red: 0.95, green: 0.97, blue: 0.99)
    
    // MARK: - Text Colors
    static let darkText = Color(red: 0.2, green: 0.2, blue: 0.3)
    static let subtleText = Color(red: 0.4, green: 0.4, blue: 0.5)
    
    // MARK: - Title Gradient
    static let titleGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.1, blue: 0.5),   // Темно-фиолетовый
            Color(red: 0.1, green: 0.2, blue: 0.5)    // Темно-синий
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Contrasted Button Gradients
    static let contrastPrimary = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.7, green: 0.4, blue: 0.8),  // Более яркий фиолетовый
            Color(red: 0.9, green: 0.5, blue: 0.7)   // Более яркий розовый
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let contrastSecondary = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.6, blue: 0.9),  // Более яркий синий
            Color(red: 0.5, green: 0.8, blue: 0.8)   // Более яркий мятный
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let contrastApple = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.8, blue: 0.6),  // Яркий зеленый
            Color(red: 0.1, green: 0.6, blue: 0.9)   // Яркий синий
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.6, blue: 0.2),  // Яркий оранжевый
            Color(red: 1.0, green: 0.4, blue: 0.1)   // Более темный оранжевый
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let bluePurpleGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.4, blue: 0.9),  // Яркий синий
            Color(red: 0.6, green: 0.3, blue: 0.8)   // Фиолетовый
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let greenGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.5, blue: 0.3),  // Темно-зеленый
            Color(red: 0.1, green: 0.6, blue: 0.6)   // Сине-зеленый
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Button Border Colors (светлее градиентов)
    static let primaryBorder = Color(red: 0.95, green: 0.75, blue: 0.9)  // Светлее розового из contrastPrimary
    static let appleBorder = Color(red: 0.7, green: 0.95, blue: 0.9)     // Светлее зеленого из contrastApple
    static let orangeBorder = Color(red: 1.0, green: 0.8, blue: 0.6)     // Светлее оранжевого градиента
    static let bluePurpleBorder = Color(red: 0.7, green: 0.75, blue: 0.95) // Светлее сине-фиолетового градиента
    static let greenBorder = Color(red: 0.5, green: 0.8, blue: 0.8)      // Светлее темно-зелено/сине-зеленого градиента
    
    // MARK: - Field Gradient
    static let fieldGradient = LinearGradient(
        gradient: Gradient(colors: [
            cloudWhite,                                   // Существующий цвет cloudWhite
            Color(red: 0.80, green: 0.84, blue: 0.94)   // Еще темнее и синее
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Shadow Colors
    static let softShadow = Color.black.opacity(0.1)
    static let mediumShadow = Color.black.opacity(0.15)
}

// MARK: - Button Styles
struct FairyButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let shadowColor: Color
    
    init(gradient: LinearGradient, shadowColor: Color = AppColors.softShadow) {
        self.gradient = gradient
        self.shadowColor = shadowColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(gradient)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: shadowColor,
                radius: configuration.isPressed ? 2 : 8,
                x: 0,
                y: configuration.isPressed ? 1 : 4
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Text Field Styles
struct FairyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(AppColors.darkText)
            .accentColor(AppColors.darkText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.cloudWhite)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
    }
} 