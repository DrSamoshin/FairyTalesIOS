//
//  StoryViewScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct StoryViewScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var storyService = StoryService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEndConfirmation = false
    @State private var fullStory: Story?
    @State private var isLoading = true
    
    let story: Story
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    @State private var iconScale: CGFloat = 1.0
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let buttonHeight: CGFloat = 54
        static let cornerRadius: CGFloat = 16
        static let iconSize: CGFloat = 80
        static let animationDuration: Double = 0.15
        static let titleAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let contentAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let buttonsAnimationDelay: UInt64 = 500_000_000 // 0.5 seconds
        static let titleAnimationDuration: Double = 0.6
        static let contentAnimationDuration: Double = 0.8
        static let buttonsAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 10
        static let bottomSpacing: CGFloat = 30
        static let buttonSpacing: CGFloat = 15
    }
    
    var body: some View {
        NavigationStack {
            storyViewContent
        }
        .alert("story_saved_title".localized, isPresented: $showingEndConfirmation) {
            if story.id != nil {
                Button("delete_story".localized, role: .destructive) {
                    if let storyId = story.id {
                        Task {
                            let success = await storyService.deleteStory(storyId: storyId)
                            if success {
                                // Refresh stories list
                                _ = await storyService.fetchUserStories()
                                // Send notification to refresh MyStoriesScreen
                                NotificationCenter.default.post(name: .storyDeleted, object: nil)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            Button("return".localized, role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("story_saved_message".localized)
        }
    }
    
    // MARK: - Main Content
    private var storyViewContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.contentPadding)
                .padding(.top, 20)
                .padding(.bottom, 6)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            scrollableContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .onAppear {
            startAnimations()
            loadFullStory()
        }
    }
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: Constants.vStackSpacing) {
                Spacer(minLength: Constants.bottomSpacing)
                titleSection
                Spacer(minLength: 20)
                storyContent
                Spacer(minLength: Constants.vStackSpacing)
                actionButtons
                Spacer(minLength: Constants.bottomSpacing)
            }
        }
    }
    
    // MARK: - Header Components
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
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(story.title)
                .font(.appStoryTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    // MARK: - Content Components
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("Loading story...")
                        .font(.appLabelMedium)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .padding(.horizontal, Constants.contentPadding)
            } else if let content = fullStory?.content {
                Text(content)
                    .font(.appStoryContent)
                    .lineSpacing(10)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, Constants.contentPadding)
            } else {
                Text("Story content not available")
                    .font(.appStoryContent)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.contentPadding)
            }
        }
        .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    // MARK: - Action Components
    private var iconButton: some View {
        Button(action: animateIcon) {
            Image("icon_6")
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .scaleEffect(iconScale)
        }
        .animatedContent(opacity: buttonsOpacity, offset: buttonsOffset)
    }
    
    private var actionButtons: some View {
        VStack(spacing: Constants.buttonSpacing) {
            theEndButton
            shareButton
        }
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: buttonsOpacity, offset: buttonsOffset)
    }
    
    private var theEndButton: some View {
        Button(action: {
            showingEndConfirmation = true
        }) {
            Text("the_end".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(AppColors.primaryBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
    }
    
    private var shareButton: some View {
        ShareLink(
            item: "\(story.title)\n\n\(fullStory?.content ?? "")",
            subject: Text("Check out this magical story!"),
            message: Text("I created this story with Fairy Tales app")
        ) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.appBody)
                Text("share_story".localized)
                    .font(.appSubtitle)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background(Color.clear)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        Image("background_4")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    // MARK: - Animation Methods
    private func startAnimations() {
        animateTitle()
        animateContent()
        animateButtons()
    }
    
    private func animateTitle() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.titleAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.titleAnimationDuration)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
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
    
    private func animateIcon() {
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            iconScale = 1.15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDuration) {
            withAnimation(.easeOut(duration: Constants.animationDuration)) {
                iconScale = 1.0
            }
        }
    }
    
    private func loadFullStory() {
        guard let storyId = story.id else {
            isLoading = false
            return
        }
        
        Task {
            let loadedStory = await storyService.fetchStory(storyId: storyId)
            await MainActor.run {
                self.fullStory = loadedStory
                self.isLoading = false
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
    let sampleStory = Story(
        id: "1",
        user_id: "user-1",
        title: "Luna's Magic Key",
        content: "Once upon a time, in a magical forest far, far away, there lived a brave little rabbit named Luna...",
        hero_name: "Luna",
        hero_names: ["Luna"],
        age: 7,
        story_style: "Adventure",
        language: "en",
        story_idea: "A brave rabbit finds a magic key",
        story_length: 3,
        child_gender: "girl",
        created_at: "2025-08-14T10:00:00Z"
    )
    
    StoryViewScreen(story: sampleStory)
}
