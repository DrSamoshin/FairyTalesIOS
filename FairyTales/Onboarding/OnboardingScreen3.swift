//
//  OnboardingScreen3.swift
//  FairyTales
//
//  Created by Assistant on 31/08/2025.
//

import SwiftUI

struct OnboardingScreen3: View {
    // MARK: - Properties
    let onNext: () -> Void
    let onSkip: () -> Void
    let storyRequest: StoryGenerateRequest?
    
    // MARK: - State
    @State private var storyService = StoryService.shared
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    @State private var showShare = false
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let buttonHeight: CGFloat = 54
        static let cornerRadius: CGFloat = 16
        static let contentAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let contentAnimationDuration: Double = 0.6
        static let vStackSpacing: CGFloat = 40
        static let headerSpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let bottomSpacing: CGFloat = 30
        static let iconSize: CGFloat = 120
        static let buttonsAnimationDelay: UInt64 = 500_000_000 // 0.5 seconds
        static let buttonsAnimationDuration: Double = 0.8
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.vStackSpacing) {
                Spacer(minLength: 120)
                titleSection
                storyContentView
                Spacer(minLength: 30)
                
                if storyService.isTypingCompleted && !storyService.currentStreamingContent.isEmpty {
                    actionButtons
                        .onAppear {
                            animateButtons()
                        }
                }
                
                Spacer(minLength: Constants.bottomSpacing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [createShareText()])
        }
        .onAppear {
            startAnimation()
            if storyRequest == nil {
                animateButtons()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            if let storyRequest = storyRequest {
                let title = storyRequest.story_name
                Text(title)
                    .font(.appH1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .animatedContent(opacity: contentOpacity, offset: contentOffset)
            } else {
                Text("Your Magical Story")
                    .font(.appH1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .animatedContent(opacity: contentOpacity, offset: contentOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
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
            Text("Creating your magical story...")
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
            Text("Generation Error")
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
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            theEndButton
            shareButton
        }
        .padding(.horizontal, Constants.contentPadding)
        .padding(.bottom, 30)
    }
    
    private var theEndButton: some View {
        Button(action: onNext) {
            Text("Continue")
                .font(.appSubtitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(AppColors.orangeGradient)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(AppColors.orangeBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
        .animatedContent(opacity: buttonsOpacity, offset: buttonsOffset)
    }
    
    private var skipOnlyButton: some View {
        VStack(spacing: 16) {
            Button(action: onSkip) {
                Text("Skip")
                    .font(.appSubtitle)
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
        .padding(.horizontal, Constants.contentPadding)
        .padding(.bottom, 30)
        .animatedContent(opacity: buttonsOpacity, offset: buttonsOffset)
    }
    
    private var shareButton: some View {
        Button(action: { showShare = true }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.appBody)
                Text("Share Story")
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
    private func startAnimation() {
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
    
    // MARK: - Streaming Methods
    private func startGeneration(with request: StoryGenerateRequest) {
        storyService.generateStoryStream(request: request)
    }
    
    // MARK: - Helper Methods
    private func createShareText() -> String {
        guard let storyRequest = storyRequest else {
            return """
            📚 My Magical Story
            
            \(storyService.currentStreamingContent)
            
            Created with FairyTales App ✨
            https://apps.apple.com/lt/app/family-fairy-tales/id6751137745
            """
        }
        
        return """
        📚 \(storyRequest.story_name)
        🌟 Heroes: \(storyRequest.heroes.map { $0.name }.joined(separator: ", "))
        
        \(storyService.currentStreamingContent)
        
        Created with FairyTales App ✨
        https://apps.apple.com/lt/app/family-fairy-tales/id6751137745
        """
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
    OnboardingScreen3(
        onNext: { print("The End tapped") },
        onSkip: { print("Skip tapped") },
        storyRequest: nil
    )
}
