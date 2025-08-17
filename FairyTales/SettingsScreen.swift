//
//  SettingsScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct SettingsScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var authManager = AuthManager.shared
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingSubscription = false
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    @State private var sectionsOpacity: Double = 0.0
    @State private var sectionsOffset: CGFloat = 20.0
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 30
        static let headerIconSize: CGFloat = 100
        static let sectionItemHeight: CGFloat = 56
        static let cornerRadius: CGFloat = 16
        static let contentAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let sectionsAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let contentAnimationDuration: Double = 0.6
        static let sectionsAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 30
        static let headerSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 16
        static let itemSpacing: CGFloat = 12
        static let itemPadding: CGFloat = 20
        static let iconFrameWidth: CGFloat = 28
        static let topPadding: CGFloat = 20
        static let titleSpacing: CGFloat = 8
        static let borderWidth: CGFloat = 2
        static let shadowRadius: CGFloat = 8
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)
        
        // Button Configurations
        struct ButtonConfig {
            let background: LinearGradient
            let border: Color
            let icon: String
            
            static let subscription = ButtonConfig(
                background: LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.6, blue: 0.0),
                        Color(red: 0.9, green: 0.5, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color(red: 1.0, green: 0.8, blue: 0.4),
                icon: "crown.fill"
            )
            
            static let language = ButtonConfig(
                background: AppColors.contrastSecondary,
                border: Color(red: 0.7, green: 0.9, blue: 0.9),
                icon: "globe"
            )
            
            static let privacy = ButtonConfig(
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
            
            static let terms = ButtonConfig(
                background: AppColors.orangeGradient,
                border: Color(red: 1.0, green: 0.9, blue: 0.7),
                icon: "doc.plaintext"
            )
            
            static let logout = ButtonConfig(
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
        }
    }
    
    var body: some View {
        settingsContent
            .navigationBarHidden(true)
            .background(backgroundView)
            .sheet(isPresented: $showingSubscription) {
                SubscriptionScreen()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                LegalContentScreen(contentType: .privacyPolicy)
            }
            .sheet(isPresented: $showingTermsOfService) {
                LegalContentScreen(contentType: .termsOfService)
            }
            .onAppear {
                startAnimations()
            }
    }
    
    private var settingsContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.topPadding)
                .animatedContent(opacity: contentOpacity, offset: contentOffset)
            
            settingsHeader
                .padding(.horizontal, Constants.horizontalPadding)
                .animatedContent(opacity: contentOpacity, offset: contentOffset)
            
            settingsSections
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.vStackSpacing)
                .opacity(sectionsOpacity)
                .offset(y: sectionsOffset)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var settingsSections: some View {
        VStack(spacing: Constants.sectionSpacing) {
            subscriptionSection
            languageSection
            legalSection
            logoutSection
        }
    }
    
    private var backButton: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.appBackIcon)
                        .foregroundColor(.white)
                    
                    Text("back".localized)
                        .font(.appBackText)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
    }
    
    private var settingsHeader: some View {
        VStack(spacing: Constants.headerSpacing) {
            headerIcon
            headerTexts
        }
    }
    
    private var headerIcon: some View {
        Image("icon_4")
            .resizable()
            .frame(width: Constants.headerIconSize, height: Constants.headerIconSize)
    }
    
    private var headerTexts: some View {
        VStack(spacing: Constants.titleSpacing) {
            titleText
            subtitleText
        }
        .frame(maxWidth: .infinity)
    }
    
    private var titleText: some View {
        Text("settings_title".localized)
            .font(.appH1)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
    
    private var subtitleText: some View {
        Text("settings_subtitle".localized)
            .font(.appSubtitle)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        Button(action: { showingSubscription = true }) {
            let config = Constants.ButtonConfig.subscription
            return settingsCard(background: config.background, borderColor: config.border) {
                subscriptionButtonContent
            }
        }
    }
    
    private var subscriptionButtonContent: some View {
        HStack(spacing: Constants.itemSpacing) {
            settingsIcon(Constants.ButtonConfig.subscription.icon)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("subscription_title".localized)
                    .font(.appLabel)
                    .foregroundColor(.white)
                
                Text("subscription_manage".localized)
                    .font(.appCaption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            chevronIcon
        }
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.appIcon)
            .foregroundColor(.white.opacity(0.7))
    }
    
    // MARK: - Language Section
    private var languageSection: some View {
        let config = Constants.ButtonConfig.language
        return settingsCard(background: config.background, borderColor: config.border) {
            HStack(spacing: Constants.itemSpacing) {
                settingsIcon(config.icon)
                
                Text("language_setting".localized)
                    .font(.appLabel)
                    .foregroundColor(.white)
                
                Spacer()
                
                languagePicker
            }
        }
    }
    
    private var languagePicker: some View {
        Picker("Language", selection: $localizationManager.currentLanguage) {
            ForEach(SupportedLanguage.allCases, id: \.self) { language in
                Text(language.nativeName)
                    .font(.appPickerItem)
                    .tag(language)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .tint(.white)
        .onChange(of: localizationManager.currentLanguage) { _, newLanguage in
            localizationManager.setLanguage(newLanguage)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: Constants.sectionSpacing) {
            privacyPolicyButton
            termsOfServiceButton
        }
    }
    
    private var privacyPolicyButton: some View {
        Button(action: { showingPrivacyPolicy = true }) {
            let config = Constants.ButtonConfig.privacy
            return settingsCard(background: config.background, borderColor: config.border) {
                legalButtonContent(
                    icon: config.icon,
                    title: "privacy_policy".localized
                )
            }
        }
    }
    
    private var termsOfServiceButton: some View {
        Button(action: { showingTermsOfService = true }) {
            let config = Constants.ButtonConfig.terms
            return settingsCard(background: config.background, borderColor: config.border) {
                legalButtonContent(
                    icon: config.icon,
                    title: "terms_of_service".localized
                )
            }
        }
    }
    
    private func legalButtonContent(icon: String, title: String) -> some View {
        HStack(spacing: Constants.itemSpacing) {
            settingsIcon(icon)
            
            Text(title)
                .font(.appLabel)
                .foregroundColor(.white)
            
            Spacer()
            
            chevronIcon
        }
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: {
            if !isLoggingOut {
                showingLogoutAlert = true
            }
        }) {
            let config = Constants.ButtonConfig.logout
            return settingsCard(background: config.background, borderColor: config.border) {
                logoutButtonContent
            }
        }
        .disabled(isLoggingOut)
        .alert("logout".localized, isPresented: $showingLogoutAlert) {
            Button("logout".localized, role: .destructive) {
                performLogout()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("logout_confirmation".localized)
        }
    }
    
    private var logoutButtonContent: some View {
        HStack(spacing: Constants.itemSpacing) {
            logoutIcon
            
            Text(isLoggingOut ? "logging_out".localized : "logout".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private var logoutIcon: some View {
        Group {
            if isLoggingOut {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
            } else {
                settingsIcon(Constants.ButtonConfig.logout.icon)
            }
        }
        .frame(width: Constants.iconFrameWidth)
    }
    
    // MARK: - Reusable Components
    private func settingsIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.appIcon)
            .foregroundColor(.white)
            .frame(width: Constants.iconFrameWidth)
    }
    
    // MARK: - Card Component
    private func settingsCard<Content: View>(
        background: LinearGradient,
        borderColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(Constants.itemPadding)
            .frame(height: Constants.sectionItemHeight)
            .frame(maxWidth: .infinity)
            .background(background)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor ?? Color.clear, lineWidth: Constants.borderWidth)
            )
            .shadow(
                color: AppColors.softShadow,
                radius: Constants.shadowRadius,
                x: Constants.shadowOffset.width,
                y: Constants.shadowOffset.height
            )
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("background_4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.softWhite.opacity(0.2),
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
        animateSections()
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
    
    private func animateSections() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.sectionsAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.sectionsAnimationDuration)) {
                    sectionsOpacity = 1.0
                    sectionsOffset = 0.0
                }
            }
        }
    }
    
    // MARK: - Actions
    private func performLogout() {
        Task {
            isLoggingOut = true
            await authManager.logout()
            isLoggingOut = false
        }
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
    NavigationView {
        SettingsScreen()
    }
} 
