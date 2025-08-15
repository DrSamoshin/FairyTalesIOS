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
    @State private var storyManager = StoryManager.shared
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
    }
    
    private var storiesContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.topPadding)
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
    
    private var headerIcon: some View {
        Image("icon_8")
            .resizable()
            .frame(width: Constants.headerIconSize, height: Constants.headerIconSize)
            .opacity(0.8)
    }
    
    private var contentSection: some View {
        Group {
            if storyManager.isLoading && stories.isEmpty {
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
                .font(.system(size: 18, weight: .medium, design: .rounded))
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
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.titleGradient)
                    .multilineTextAlignment(.center)
                
                Text("no_stories_subtitle".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.subtleText)
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
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(AppColors.primaryBorder, lineWidth: Constants.borderWidth)
                )
                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }
    
    private var storiesListView: some View {
        List {
            ForEach(stories) { story in
                storyCard(story)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(
                        top: Constants.cardSpacing/2,
                        leading: Constants.horizontalPadding,
                        bottom: Constants.cardSpacing/2,
                        trailing: Constants.horizontalPadding
                    ))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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
            .background(AppColors.cloudWhite)
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
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.darkText)
                    .lineLimit(1)
                
                Text("hero_prefix".localized(story.hero_name ?? ""))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.fairyPurple)
            }
            
            Spacer()
            
            Text(dateFromString(story.created_at ?? ""), style: .date)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.subtleText)
        }
    }
    
    private func storyCardPreview(_ story: Story) -> some View {
        Text(String(story.content.prefix(150)) + (story.content.count > 150 ? "..." : ""))
            .font(.system(size: 15, weight: .regular, design: .serif))
            .foregroundColor(AppColors.subtleText)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .lineSpacing(2)
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("background_6")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.softWhite.opacity(0.5),
                    AppColors.cloudWhite.opacity(0.2)
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
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
    
    private func loadStories() {
        Task {
            let fetchedStories = await storyManager.fetchUserStories()
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