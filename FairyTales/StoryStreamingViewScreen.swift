//
//  StoryStreamingViewScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct StoryStreamingViewScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var storyManager = StoryManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEndConfirmation = false
    
    // Story parameters
    let storyName: String
    let heroName: String
    let age: Int
    let storyStyle: String
    let language: String
    let storyIdea: String
    
    // Streaming state
    @State private var streamingTitle: String = ""
    @State private var streamingContent: String = ""
    @State private var isStreamingComplete = false
    @State private var streamingError: String?
    @State private var showStreamingError = false
    @State private var finalStory: Story?
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    @State private var iconScale: CGFloat = 1.0
    
    // Typewriter effect
    @State private var displayedContent: String = ""
    @State private var typewriterTimer: Timer?
    @State private var currentContentIndex = 0
    
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
        static let animationDurationStandard: Double = 0.6
        static let typewriterSpeed: Double = 0.03 // seconds per character
    }
    
    var body: some View {
        NavigationStack {
            mainContent
        }
        .onAppear(perform: startStreaming)
        .onDisappear(perform: cleanup)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.contentPadding)
                .padding(.top, 20)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            ScrollView {
                VStack(spacing: 10) {
                    Spacer(minLength: 30)
                    titleSection
                    Spacer(minLength: 20)
                    contentSection
                    Spacer(minLength: 10)
                    if isStreamingComplete {
                        iconButton
                        Spacer(minLength: 10)
                        actionButtons
                    }
                    Spacer(minLength: 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .overlay(
            customAlert
        )
    }
    
    // MARK: - Header Components
    private var backButton: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("back".localized)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            titleTexts
        }
    }
    
    private var titleTexts: some View {
        VStack(spacing: 8) {
            Text(streamingTitle.isEmpty ? storyName : streamingTitle)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    // MARK: - Content Components
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if displayedContent.isEmpty && !isStreamingComplete {
                streamingIndicator
            } else {
                Text(displayedContent)
                    .font(.system(size: 18, design: .serif))
                    .lineSpacing(10)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, Constants.contentPadding)
                    .animatedContent(opacity: contentOpacity, offset: contentOffset)
            }
        }
    }
    
    private var streamingIndicator: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                
                Text("creating_magic".localized)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text("please_wait_generating".localized)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Constants.contentPadding)
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
        VStack(spacing: 15) {
            // The End Button
            Button(action: {
                showingEndConfirmation = true
            }) {
                Text("the_end".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
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
            
            // Share Button
            if let story = finalStory {
                ShareLink(
                    item: "\(story.title)\n\n\(story.content)",
                    subject: Text("Check out this magical story!"),
                    message: Text("I created this story with Fairy Tales app")
                ) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                        Text("share_story".localized)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
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
        }
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: buttonsOpacity, offset: buttonsOffset)
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            Image("background_4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var customAlert: some View {
        if showStreamingError {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showStreamingError = false
                    }
                
                VStack(spacing: 20) {
                    Text("Error")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.darkText)
                        .multilineTextAlignment(.center)
                    
                    Text(streamingError ?? "Unknown error")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        streamingError = nil
                        showStreamingError = false
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("OK")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.contrastPrimary)
                            .cornerRadius(Constants.cornerRadius)
                            .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(30)
                .background(AppColors.cloudWhite)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: AppColors.mediumShadow, radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40)
                .scaleEffect(showStreamingError ? 1.0 : 0.8)
                .opacity(showStreamingError ? 1.0 : 0.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showStreamingError)
            }
        }
    }
    
    // MARK: - Animation Methods
    private func startAnimations() {
        // Title animation
        Task {
            try? await Task.sleep(nanoseconds: Constants.titleAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.animationDurationStandard)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
            }
        }
        
        // Content animation
        Task {
            try? await Task.sleep(nanoseconds: Constants.contentAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.animationDurationStandard)) {
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
                withAnimation(.easeOut(duration: Constants.animationDurationStandard)) {
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
    
    // MARK: - Streaming Methods
    private func startStreaming() {
        startAnimations()
        
        storyManager.generateStoryStream(
            storyName: storyName,
            heroName: heroName,
            age: age,
            storyStyle: storyStyle,
            language: language,
            storyIdea: storyIdea,
            onChunk: { chunk in
                handleStreamChunk(chunk)
            },
            onComplete: { story in
                handleStreamComplete(story)
            },
            onError: { error in
                streamingError = error
                showStreamingError = true
            }
        )
    }
    
    private func handleStreamChunk(_ chunk: StreamChunk) {
        guard let data = chunk.data else { return }
        
        if let title = data.title, !title.isEmpty {
            streamingTitle = title
        }
        
        if let content = data.chunk, !content.isEmpty {
            streamingContent += content
            startTypewriterEffect()
        }
    }
    
    private func handleStreamComplete(_ story: Story?) {
        finalStory = story
        isStreamingComplete = true
        
        // Ensure all content is displayed
        displayedContent = streamingContent
        
        // Animate buttons
        animateButtons()
        
        // Send notification
        NotificationCenter.default.post(name: .init("StoryCreated"), object: nil)
    }
    
    // MARK: - Typewriter Effect
    private func startTypewriterEffect() {
        // Stop existing timer
        typewriterTimer?.invalidate()
        
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: Constants.typewriterSpeed, repeats: true) { _ in
            if currentContentIndex < streamingContent.count {
                let index = streamingContent.index(streamingContent.startIndex, offsetBy: currentContentIndex)
                displayedContent = String(streamingContent[...index])
                currentContentIndex += 1
            } else {
                typewriterTimer?.invalidate()
                typewriterTimer = nil
            }
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
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
    StoryStreamingViewScreen(
        storyName: "Luna's Adventure",
        heroName: "Luna",
        age: 7,
        storyStyle: "Adventure",
        language: "en",
        storyIdea: "A magical journey through an enchanted forest"
    )
}
