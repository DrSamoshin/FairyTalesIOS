//
//  StoryStreamingScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct StoryStreamingScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var storyService = StoryService.shared
    @Environment(\.dismiss) private var dismiss
    
    let storyData: StoryGenerateRequest
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    @State private var iconScale: CGFloat = 1.0
    
    // UI state
    @State private var showingAlert = false
    @State private var showShare = false
    @State private var showingEndConfirmation = false
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 54
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
            streamingContent
        }
        .alert("generation_error".localized, isPresented: $showingAlert) {
            alertButtons
        } message: {
            Text(storyService.errorMessage ?? "unknown_error".localized)
        }
        .onChange(of: storyService.errorMessage) { _, newError in
            showingAlert = newError != nil
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [createShareText()])
        }
        .alert("story_saved_title".localized, isPresented: $showingEndConfirmation) {
            if storyService.streamingStoryId != nil {
                Button("delete_story".localized, role: .destructive) {
                    if let storyId = storyService.streamingStoryId {
                        Task {
                            let success = await storyService.deleteStory(storyId: storyId)
                            if success {
                                // Refresh stories list
                                _ = await storyService.fetchUserStories()
                                // Send notification to refresh MyStoriesScreen
                                NotificationCenter.default.post(name: .storyDeleted, object: nil)
                            }
                            dismiss()
                        }
                    }
                }
            }
            Button("return".localized, role: .cancel) {
                // Dismiss twice to go back to MainScreen
                dismiss()
            }
        } message: {
            Text("story_saved_message".localized)
        }
    }
    
    // MARK: - Main Content
    private var streamingContent: some View {
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
            startGeneration()
        }
        .onDisappear {
            // Cleanup when screen disappears
        }
    }
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: Constants.vStackSpacing) {
                Spacer(minLength: Constants.bottomSpacing)
                titleSection
                Spacer(minLength: 20)
                storyContentView
                Spacer(minLength: Constants.vStackSpacing)
                
                if storyService.isTypingCompleted && !storyService.currentStreamingContent.isEmpty {
                    actionButtons
                        .onAppear {
                            animateButtons()
                        }
                }
                
                Spacer(minLength: Constants.bottomSpacing)
            }
        }
    }
    
    @ViewBuilder
    private var alertButtons: some View {
        Button("OK") {
            storyService.errorMessage = nil
        }
        Button("retry".localized) {
            startGeneration()
        }
    }
    
    // MARK: - Header Components
    private var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
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
            Text(storyData.story_name)
                .font(.appH1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    // MARK: - Content Components
    private var storyContentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !storyService.currentStreamingContent.isEmpty {
                Text(storyService.currentStreamingContent)
                    .font(.appStoryContent)
                    .lineSpacing(10)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, Constants.contentPadding)
                    .id("storyContent")
            } else if storyService.isStreaming {
                loadingState
            } else if let errorMessage = storyService.errorMessage {
                errorState(errorMessage)
            }
        }
        .animatedContent(opacity: contentOpacity, offset: contentOffset)
    }
    
    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            Text("waiting_for_story".localized)
                .font(.appLabelMedium)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    private func errorState(_ errorMessage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.appEmoji)
                .foregroundColor(.orange)
            Text("generation_error".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
            Text(errorMessage)
                .font(.appCaption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(.horizontal, Constants.contentPadding)
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
        Button(action: { showingEndConfirmation = true }) {
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
        Button(action: { showShare = true }) {
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
        Image("bg_13")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    // MARK: - Animation Methods
    private func startAnimations() {
        animateTitle()
        animateContent()
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
    
    // MARK: - Helper Methods
    private func startGeneration() {
        storyService.generateStoryStream(request: storyData)
    }
    
    private func createShareText() -> String {
        """
        📚 \(storyData.story_name)
        🌟 Heroes: \(storyData.heroes.map { $0.name }.joined(separator: ", "))
        
        \(storyService.currentStreamingContent)
        
        Created with FairyTales App ✨
        https://apps.apple.com/lt/app/family-fairy-tales/id6751137745
        """
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
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
    StoryStreamingScreen(storyData: StoryGenerateRequest(
        story_name: "Test Story",
        story_idea: "A magical adventure",
        story_style: "Adventure",
        language: "en",
        story_length: 3,
        heroes: []
    ))
}
