//
//  MainScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct MainScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var logoScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    @State private var showSubscriptionScreen = false
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let logoSize: CGFloat = 100
        static let mainButtonHeight: CGFloat = 70
        static let settingsButtonHeight: CGFloat = 54
        static let cornerRadius: CGFloat = 16
        static let logoAnimationDuration: Double = 0.15
        static let contentAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let buttonsAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let contentAnimationDuration: Double = 0.6
        static let buttonsAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 40
        static let headerSpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let buttonSpacing: CGFloat = 20
        static let buttonIconSize: CGFloat = 40
        static let bottomSpacing: CGFloat = 30
        static let buttonContentPadding: CGFloat = 20
        static let buttonContentSpacing: CGFloat = 20
        static let textSpacing: CGFloat = 4
        
        // Using shared button styles
        typealias ButtonConfig = ButtonStyles.ButtonConfig
    }
    
    var body: some View {
        NavigationStack {
            homeContent
        }
        .sheet(isPresented: $showSubscriptionScreen) {
            SubscriptionScreen()
        }
    }
    
    private var homeContent: some View {
        VStack(spacing: Constants.vStackSpacing) {
            Spacer()
            homeHeader
            Spacer()
            actionButtons
            Spacer()
            settingsNavigationButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .onAppear {
            startAnimations()
            // Refresh subscription status when returning to main screen
            Task {
                await subscriptionManager.checkSubscriptionStatusIfNeeded()
            }
        }
    }
    
    private var homeHeader: some View {
        VStack(spacing: Constants.headerSpacing) {
            headerTexts
        }
    }
    
    private var headerTexts: some View {
        VStack(spacing: Constants.titleSpacing) {
            titleText
            subtitleText
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    private var titleText: some View {
        Text("main_title".localized)
            .font(.appH1)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    private var subtitleText: some View {
        Text("main_subtitle".localized)
            .font(.appSubtitle)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    private var actionButtons: some View {
        VStack(spacing: Constants.buttonSpacing) {
            createStoryNavigationButton
            myStoriesNavigationButton
            heroesNavigationButton
        }
        .padding(.horizontal, Constants.contentPadding)
        .opacity(buttonsOpacity)
        .offset(y: buttonsOffset)
    }
    
    private var createStoryNavigationButton: some View {
        Group {
            if subscriptionManager.canCreateStory() {
                NavigationLink(destination: StoryCreatorScreen()) {
                    actionButton(
                        iconName: "i_4",
                        title: "create_new_story".localized,
                        subtitle: "create_story_subtitle".localized,
                        config: Constants.ButtonConfig.lavenderPurple,
                        textColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: {
                    showSubscriptionScreen = true
                }) {
                    actionButton(
                        iconName: "i_4",
                        title: "create_new_story".localized,
                        subtitle: "create_story_subtitle".localized,
                        config: Constants.ButtonConfig.lavenderPurple,
                        textColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var myStoriesNavigationButton: some View {
        Group {
            if subscriptionManager.canViewStories() {
                NavigationLink(destination: MyStoriesScreen()) {
                    actionButton(
                        iconName: "i_3",
                        title: "my_stories".localized,
                        subtitle: "my_stories_subtitle".localized,
                        config: Constants.ButtonConfig.skyBlue,
                        textColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: {
                    showSubscriptionScreen = true
                }) {
                    actionButton(
                        iconName: "i_3",
                        title: "my_stories".localized,
                        subtitle: "my_stories_subtitle".localized,
                        config: Constants.ButtonConfig.skyBlue,
                        textColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var heroesNavigationButton: some View {
        Group {
            if subscriptionManager.canViewStories() {
                NavigationLink(destination: HeroesScreen()) {
                    actionButton(
                        iconName: "i_2",
                        title: "heroes".localized,
                        subtitle: "heroes_subtitle".localized,
                        config: Constants.ButtonConfig.limeGreen,
                        textColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: {
                    showSubscriptionScreen = true
                }) {
                    actionButton(
                        iconName: "i_2",
                        title: "heroes".localized,
                        subtitle: "heroes_subtitle".localized,
                        config: Constants.ButtonConfig.limeGreen,
                        textColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func actionButton(
        iconName: String,
        title: String,
        subtitle: String,
        config: ButtonStyles.ButtonConfig,
        textColor: Color
    ) -> some View {
        HStack(spacing: Constants.buttonContentSpacing) {
            Image(iconName)
                .resizable()
                .frame(width: Constants.buttonIconSize, height: Constants.buttonIconSize)
            
            VStack(alignment: .leading, spacing: Constants.textSpacing) {
                Text(title)
                    .font(.appSubtitle)
                    .foregroundColor(textColor)
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(textColor.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.appBackIcon)
                .foregroundColor(textColor.opacity(0.7))
        }
        .styledButtonCard(config: config, height: Constants.mainButtonHeight)
    }
    
    private var settingsNavigationButton: some View {
        NavigationLink(destination: SettingsScreen()) {
            Text("settings".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.settingsButtonHeight)
                .background(Color.clear)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
        .padding(.horizontal, Constants.contentPadding)
        .padding(.bottom, Constants.bottomSpacing)
        .opacity(buttonsOpacity)
        .offset(y: buttonsOffset)
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("bg_3")
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
    
    // MARK: - Animation Methods
    private func startAnimations() {
        animateContent()
        animateButtons()
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
    
    private func animateButtons() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.buttonsAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.buttonsAnimationDuration)) {
                    buttonsOpacity = 1.0
                    buttonsOffset = 0.0
                }
            }
        }
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
    MainScreen()
}
