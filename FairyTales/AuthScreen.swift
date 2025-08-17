//
//  AuthScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI
import AuthenticationServices

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            await authManager.signInWithApple(authorization: authorization)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            handleAppleSignInError(error)
        }
    }
    
    private func handleAppleSignInError(_ error: Error) {
        guard let authError = error as? ASAuthorizationError else {
            authManager.errorMessage = "apple_signin_general_error".localized
            return
        }
        
        switch authError.code {
        case .canceled:
            // User canceled - don't show error
            return
        case .unknown:
            authManager.errorMessage = "apple_signin_unknown_error".localized
        case .invalidResponse:
            authManager.errorMessage = "apple_signin_invalid_response".localized
        case .notHandled:
            authManager.errorMessage = "apple_signin_not_handled".localized
        case .notInteractive:
            authManager.errorMessage = "apple_signin_not_interactive".localized
        case .failed:
            authManager.errorMessage = "apple_signin_failed".localized
        case .matchedExcludedCredential:
            authManager.errorMessage = "apple_signin_excluded_credential".localized
        case .credentialImport:
            authManager.errorMessage = "apple_signin_credential_import".localized
        case .credentialExport:
            authManager.errorMessage = "apple_signin_credential_export".localized
        @unknown default:
            authManager.errorMessage = "apple_signin_unknown_error".localized
        }
    }
}

struct AuthScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var authManager = AuthManager.shared
    @Environment(HealthCheckManager.self) private var healthCheckManager
    @State private var logoScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    @State private var backgroundScale: CGFloat = 1.0
    @State private var showingAlert = false
    @State private var appleSignInDelegate: AppleSignInDelegate?
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let logoSize: CGFloat = 120
        static let buttonHeight: CGFloat = 54
        static let logoAnimationDuration: Double = 0.15
        static let backgroundAnimationDuration: Double = 12.0
        static let contentAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let contentAnimationDuration: Double = 0.6
        static let vStackSpacing: CGFloat = 40
        static let headerSpacing: CGFloat = 16
        static let bottomSpacing: CGFloat = 20
    }
    
    var body: some View {
        NavigationStack {
            welcomeScreen
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { authManager.errorMessage = nil }
        } message: {
            Text(authManager.errorMessage ?? "Unknown error")
        }
        .onChange(of: authManager.errorMessage) { _, newError in
            showingAlert = newError != nil
        }

    }
    
    private var welcomeScreen: some View {
        VStack(spacing: Constants.vStackSpacing) {
            Spacer()
            welcomeHeader
            Spacer()
            Spacer()
            welcomeDescription
            signInButton
            Spacer(minLength: Constants.bottomSpacing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .onAppear {
            startAnimations()
        }
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: Constants.headerSpacing) {
//            logoButton
            headerTexts
        }
    }
    
    private var logoButton: some View {
        Button(action: animateLogo) {
            Image("icon_6")
                .resizable()
                .frame(width: Constants.logoSize, height: Constants.logoSize)
                .scaleEffect(logoScale)
        }
    }
    
    private var headerTexts: some View {
        VStack(spacing: Constants.headerSpacing) {
            titleText
            subtitleText
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    private var titleText: some View {
        Text("app_title".localized)
            .font(.appH1)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    private var subtitleText: some View {
        Text("welcome_subtitle".localized)
            .font(.appSubtitle)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    private var welcomeDescription: some View {
        Text("welcome_description".localized)
            .font(.appLabelMedium)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, Constants.contentPadding + 20)
            .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    

    
    private var signInButton: some View {
        Button(action: performAppleSignIn) {
            HStack {
                Image(systemName: "applelogo")
                    .foregroundColor(.white)
                Text("Sign in with Apple")
                    .foregroundColor(.white)
                    .font(.appH3)
            }
            .frame(height: Constants.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(AppColors.greenGradient)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.greenBorder, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
        .disabled(authManager.isLoading)
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("background_13")
                .resizable()
                .scaledToFill()
                .scaleEffect(backgroundScale)
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
    
    // MARK: - Animation Methods
    private func startAnimations() {
        animateContent()
        animateBackground()
    }
    
    private func animateLogo() {
        withAnimation(.easeInOut(duration: Constants.logoAnimationDuration)) {
            logoScale = 1.15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.logoAnimationDuration) {
            withAnimation(.easeOut(duration: Constants.logoAnimationDuration)) {
                logoScale = 1.0
            }
        }
    }
    
    private func animateContent() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.contentAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.contentAnimationDuration)) {
                    contentOpacity = 1.0
                    contentOffset = 0.0
                }
            }
        }
    }
    
    private func animateBackground() {
        withAnimation(.easeInOut(duration: Constants.backgroundAnimationDuration).repeatForever(autoreverses: true)) {
            backgroundScale = 1.1
        }
    }
    
    private func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        appleSignInDelegate = AppleSignInDelegate(authManager: authManager)
        controller.delegate = appleSignInDelegate
        controller.performRequests()
    }
}

// MARK: - View Extensions
private extension View {
    func animatedContent(opacity: Double, offset: CGFloat) -> some View {
        self
            .opacity(opacity)
            .offset(y: offset)
    }
}

#Preview {
    AuthScreen()
}
