//
//  AuthScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI
import AuthenticationServices

struct AuthScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var isLoggedIn = false
    @State private var iconScale: CGFloat = 1.0
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    
    private let horizontalPadding: CGFloat = 30
    private let iconSize: CGFloat = 120
    private let buttonHeight: CGFloat = 54
    private let animationDuration: Double = 0.15
    
    var body: some View {
        NavigationStack {
            if isLoggedIn {
                MainScreen()
            } else {
                authView
            }
        }
    }
    
    private var authView: some View {
        VStack(spacing: 30) {
            Spacer()
            titleSection
            Spacer()
            authForm
            divider
            appleSignInButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .onTapGesture(perform: hideKeyboard)
        .onAppear(perform: animateTitle)
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            animatedIcon
            titleTexts
        }
    }
    
    private var animatedIcon: some View {
        Button(action: animateIcon) {
            Image("icon_4")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .scaleEffect(iconScale)
        }
    }
    
    private var titleTexts: some View {
        VStack(spacing: 8) {
            Text("app_title".localized)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.titleGradient)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            
            Text("app_subtitle".localized)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.subtleText)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
    }
    
    private var authForm: some View {
        VStack(spacing: 20) {
            emailField
            passwordField
            primaryButton
            toggleButton
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private var emailField: some View {
        ZStack(alignment: .leading) {
            if email.isEmpty {
                Text("email_placeholder".localized)
                    .foregroundColor(Color.gray)
                    .font(.system(size: 16, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            TextField("", text: $email)
                .foregroundColor(AppColors.darkText)
                .font(.system(size: 16, design: .rounded))
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(AppColors.cloudWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
        )
        .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
    }
    
    private var passwordField: some View {
        ZStack(alignment: .leading) {
            if password.isEmpty {
                Text("password_placeholder".localized)
                    .foregroundColor(Color.gray)
                    .font(.system(size: 16, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            SecureField("", text: $password)
                .foregroundColor(AppColors.darkText)
                .font(.system(size: 16, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(AppColors.cloudWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
        )
        .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
    }
    
    private var primaryButton: some View {
        Button(action: performEmailAuth) {
            Text(isLogin ? "sign_in".localized : "sign_up".localized)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.primaryBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
    }
    
    private var toggleButton: some View {
        Button(action: toggleAuthMode) {
            Text(isLogin ? "no_account".localized : "have_account".localized)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.darkText)
                .underline()
        }
    }
    
    private var divider: some View {
        HStack {
            Rectangle()
                .fill(AppColors.darkText.opacity(0.2))
                .frame(height: 1)
            Text("or_divider".localized)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.darkText)
                .padding(.horizontal, 8)
            Rectangle()
                .fill(AppColors.darkText.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private var appleSignInButton: some View {
        Button(action: performAppleAuth) {
            Text("Sign in with Apple")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(AppColors.contrastApple)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.appleBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("background_1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.softWhite.opacity(0.3),
                    AppColors.cloudWhite.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    private func animateIcon() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            iconScale = 1.15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.easeOut(duration: animationDuration)) {
                iconScale = 1.0
            }
        }
    }
    
    private func animateTitle() {
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.6)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
            }
        }
    }
    
    private func performEmailAuth() {
        print("Email \(isLogin ? "login" : "register") tapped")
        isLoggedIn = true
    }
    
    private func performAppleAuth() {
        print("Apple Sign In tapped")
        isLoggedIn = true
    }
    
    private func toggleAuthMode() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLogin.toggle()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AuthScreen()
} 
