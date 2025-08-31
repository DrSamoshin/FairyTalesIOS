//
//  MyStoriesScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct MyStoriesScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var storyService = StoryService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedStory: Story?
    @State private var showStoryView = false
    @State private var showStoryCreator = false
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20.0
    @State private var stories: [Story] = []
    @State private var isFirstLoad = true
    @State private var showSubscriptionPrompt = false
    
    // MARK: - Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 30
        static let topPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 16
        static let cardSpacing: CGFloat = 16
        static let buttonHeight: CGFloat = 54
        static let headerIconSize: CGFloat = 100
        static let contentAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let titleAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let contentAnimationDuration: Double = 0.6
        static let titleAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 30
        static let headerSpacing: CGFloat = 12
        static let titleSpacing: CGFloat = 8
        static let cardPadding: CGFloat = 20
        static let shadowRadius: CGFloat = 4
        static let shadowOffset: CGSize = CGSize(width: 0, height: 2)
        static let emptyStatePadding: CGFloat = 40
        static let borderWidth: CGFloat = 2
    }

    var body: some View {
        Group {
            if subscriptionManager.canViewStories() {
                NavigationStack {
                    storiesContent
                }
                .navigationBarHidden(true)
                .background(backgroundView)
                .onAppear(perform: startAnimations)
                .onReceive(NotificationCenter.default.publisher(for: .init("StoryCreated"))) { _ in
                    loadStories()
                }
                .onReceive(NotificationCenter.default.publisher(for: .storyDeleted)) { _ in
                    loadStories()
                }
                .navigationDestination(isPresented: $showStoryView) {
                    if let story = selectedStory {
                        StoryViewScreen(story: story)
                    } else {
                        EmptyView()
                    }
                }
                .navigationDestination(isPresented: $showStoryCreator) {
                    StoryCreatorScreen()
                }
            } else {
                // Show subscription screen directly
                SubscriptionScreen()
            }
        }
        .onAppear {
            Task {
                await subscriptionManager.checkSubscriptionStatusIfNeeded()
            }
        }
    }
    
    private var storiesContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.topPadding)
                .padding(.bottom, 6)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            contentSection
                .padding(.top, Constants.vStackSpacing)
                .animatedContent(opacity: contentOpacity, offset: contentOffset)
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
    
    private var headerIcon: some View {
        Image("icon_8")
            .resizable()
            .frame(width: Constants.headerIconSize, height: Constants.headerIconSize)
            .opacity(0.8)
    }
    
    private var contentSection: some View {
        Group {
            if storyService.isLoading && stories.isEmpty {
                loadingView
            } else if stories.isEmpty {
                emptyStateView
            } else {
                storiesListView
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("loading_stories".localized)
                .font(.appBody)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Constants.vStackSpacing) {
            Spacer()
            
            headerIcon
            
            VStack(spacing: Constants.headerSpacing) {
                Text("no_stories_title".localized)
                    .font(.appH1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("no_stories_subtitle".localized)
                    .font(.appSubtitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Constants.emptyStatePadding)
            
            createStoryButton
            
            Spacer()
        }
    }
    
    private var createStoryButton: some View {
        Button(action: {
            showStoryCreator = true
        }) {
            Text("create_story".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Color(red: 0.95, green: 0.75, blue: 0.85), lineWidth: 2)
                )
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }
    
    private var storiesListView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.cardSpacing) {
                ForEach(stories) { story in
                    storyCard(story)
                        .padding(.horizontal, Constants.horizontalPadding)
                }
            }
            .padding(.vertical, Constants.cardSpacing)
        }
    }
    
    private func storyCard(_ story: Story) -> some View {
        Button(action: {
            selectedStory = story
            showStoryView = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                storyCardHeader(story)
                storyCardPreview(story)
            }
            .padding(Constants.cardPadding)
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: Constants.borderWidth)
            )
            .shadow(
                color: AppColors.softShadow,
                radius: Constants.shadowRadius,
                x: Constants.shadowOffset.width,
                y: Constants.shadowOffset.height
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func storyCardHeader(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(story.title)
                    .font(.appSubtitle)
                    .foregroundColor(AppColors.darkText)
                    .lineLimit(1)
                
                Spacer()
                
                Text(dateFromString(story.created_at ?? ""), format: .dateTime.day().month().year().hour().minute())
                    .font(.appSmall)
                    .foregroundColor(AppColors.subtleText)
            }
            
            if let heroNames = story.hero_names, !heroNames.isEmpty {
                Text("heroes_prefix".localized + heroNames.joined(separator: ", "))
                    .font(.appCaption)
                    .foregroundColor(AppColors.fairyPurple)
                    .lineLimit(1)
            }
        }
    }
    
    private func storyCardPreview(_ story: Story) -> some View {
        if let storyIdea = story.story_idea, !storyIdea.isEmpty {
            Text(storyIdea)
                .font(.appStoryPreview)
                .foregroundColor(AppColors.subtleText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
        } else {
            Text("No story idea available")
                .font(.appStoryPreview)
                .foregroundColor(AppColors.subtleText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("bg_6")
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
        if isFirstLoad {
            loadStories()
            isFirstLoad = false
        }
        
        animateTitle()
        animateContent()
    }
    
    private func animateTitle() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.contentAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.contentAnimationDuration)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
            }
        }
    }
    
    private func animateContent() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.titleAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.titleAnimationDuration)) {
                    contentOpacity = 1.0
                    contentOffset = 0.0
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func dateFromString(_ dateString: String) -> Date {
        return DateFormatter.parseUTCDate(from: dateString)
    }
    
    private func loadStories() {
        Task {
            let fetchedStories = await storyService.fetchUserStories()
            await MainActor.run {
                self.stories = fetchedStories
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
    MyStoriesScreen()
}
