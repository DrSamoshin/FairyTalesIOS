//
//  HeroesScreen.swift
//  FairyTales
//
//  Created by Assistant on 27/08/2025.
//

import SwiftUI

struct HeroesScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var heroService = HeroService.shared
    @State private var heroes: [Hero] = []
    @State private var isLoading = false
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    @State private var heroesOpacity: Double = 0.0
    @State private var heroesOffset: CGFloat = 20.0
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 30
        static let headerIconSize: CGFloat = 100
        static let cornerRadius: CGFloat = 16
        static let contentAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let heroesAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let contentAnimationDuration: Double = 0.6
        static let heroesAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 30
        static let headerSpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let topPadding: CGFloat = 20
        static let createButtonHeight: CGFloat = 70
        static let heroCardHeight: CGFloat = 80
        static let heroIconSize: CGFloat = 40
        static let heroContentSpacing: CGFloat = 16
        static let scrollContentSpacing: CGFloat = 16
        
        // Using shared button styles
        typealias ButtonConfig = ButtonStyles.ButtonConfig
        
        // Hero card colors
        static let boyGradientColor = Color(red: 0.7, green: 0.85, blue: 1.0) // Light blue
        static let girlGradientColor = Color(red: 1.0, green: 0.8, blue: 0.9) // Light pink
        static let cardBorderColor = Color.white
        static let cardBorderWidth: CGFloat = 2
    }
    
    var body: some View {
        heroesContent
            .navigationBarHidden(true)
            .background(backgroundView)
            .onAppear {
                startAnimations()
                loadHeroes()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HeroCreated"))) { _ in
                // Reload heroes when a new hero is created
                loadHeroes()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HeroUpdated"))) { _ in
                // Reload heroes when a hero is updated
                loadHeroes()
            }
    }
    
    private var heroesContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.topPadding)
                .animatedContent(opacity: contentOpacity, offset: contentOffset)
            
            heroesHeader
                .padding(.horizontal, Constants.horizontalPadding)
                .animatedContent(opacity: contentOpacity, offset: contentOffset)
            
            createHeroButton
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.vStackSpacing)
                .opacity(heroesOpacity)
                .offset(y: heroesOffset)
            
            heroesScrollView
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.scrollContentSpacing)
                .opacity(heroesOpacity)
                .offset(y: heroesOffset)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    private var heroesHeader: some View {
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
    }
    
    private var titleText: some View {
        Text("heroes".localized)
            .font(.appH1)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }
    
    private var subtitleText: some View {
        Text("heroes_subtitle".localized)
            .font(.appSubtitle)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }
    
    private var createHeroButton: some View {
        NavigationLink(destination: HeroCreatorScreen()) {
            HStack(spacing: Constants.heroContentSpacing) {
                Image("i_2")
                    .resizable()
                    .frame(width: Constants.heroIconSize, height: Constants.heroIconSize)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("create_hero".localized)
                        .font(.appSubtitle)
                        .foregroundColor(.white)
                    Text("create_hero_subtitle".localized)
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.appBackIcon)
                    .foregroundColor(.white.opacity(0.7))
            }
            .styledButtonCard(config: Constants.ButtonConfig.limeGreen, height: Constants.createButtonHeight)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var heroesScrollView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.scrollContentSpacing) {
                if isLoading {
                    loadingView
                } else if heroes.isEmpty {
                    emptyStateView
                } else {
                    ForEach(heroes) { hero in
                        NavigationLink(destination: HeroEditScreen(hero: hero)) {
                            heroCard(hero)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            
            Text("loading_heroes".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("no_heroes_yet".localized)
                .font(.appH2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func hasAnyDetails(_ hero: Hero) -> Bool {
        return (hero.appearance?.isEmpty == false) || 
               (hero.personality?.isEmpty == false) || 
               (hero.power?.isEmpty == false)
    }
    
    private func heroCard(_ hero: Hero) -> some View {
        VStack(spacing: 0) {
            // Header section with name and age
            HStack(spacing: 8) {
                Text(hero.name)
                    .font(.appH2)
                    .foregroundColor(AppColors.darkText)
                
                Spacer()
                
                Text("age_format".localized(hero.age))
                    .font(.appCaption)
                    .foregroundColor(AppColors.darkText.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, hasAnyDetails(hero) ? 12 : 0)
            
            // Details section
            HStack(spacing: 0){
                VStack(alignment: .leading, spacing: 6) {
                    if let appearance = hero.appearance, !appearance.isEmpty {
                        Text(appearance)
                            .font(.appCaption)
                            .foregroundColor(AppColors.darkText.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    if let personality = hero.personality, !personality.isEmpty {
                        Text(personality)
                            .font(.appCaption)
                            .foregroundColor(AppColors.darkText.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    if let power = hero.power, !power.isEmpty {
                        Text(power)
                            .font(.appCaption)
                            .foregroundColor(AppColors.darkText.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                Spacer()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    hero.gender == "boy" ? Constants.boyGradientColor : Constants.girlGradientColor
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .strokeBorder(Constants.cardBorderColor, lineWidth: Constants.cardBorderWidth)
        )
        .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
    }
    
    
    private var backgroundView: some View {
        ZStack {
            Image("bg_4")
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
        animateHeroes()
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
    
    private func animateHeroes() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.heroesAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.heroesAnimationDuration)) {
                    heroesOpacity = 1.0
                    heroesOffset = 0.0
                }
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadHeroes() {
        isLoading = true
        
        Task {
            let fetchedHeroes = await heroService.fetchUserHeroes()
            await MainActor.run {
                isLoading = false
                heroes = fetchedHeroes
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
    NavigationView {
        HeroesScreen()
    }
}
