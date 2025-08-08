//
//  MyStoriesScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct Story: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let dateCreated: Date
    let heroName: String
}

struct MyStoriesScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedStory: Story?
    @State private var showStoryView = false
    @State private var showStoryCreator = false
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20.0
    @State private var stories: [Story] = [
        Story(
            title: "Luna's Magic Key",
            preview: "Once upon a time, in a magical forest far, far away, there lived a brave little rabbit named Luna...",
            dateCreated: Date().addingTimeInterval(-86400 * 2),
            heroName: "Luna"
        ),
        Story(
            title: "The Brave Knight's Quest",
            preview: "In a distant kingdom, a young knight named Alex discovered a mysterious map that would lead to...",
            dateCreated: Date().addingTimeInterval(-86400 * 5),
            heroName: "Alex"
        ),
        Story(
            title: "The Magical Garden",
            preview: "Emma found herself in a garden where flowers could sing and trees could dance...",
            dateCreated: Date().addingTimeInterval(-86400 * 10),
            heroName: "Emma"
        )
    ]
    
    private let horizontalPadding: CGFloat = 30
    private let cornerRadius: CGFloat = 16
    private let cardSpacing: CGFloat = 16
    private let buttonHeight: CGFloat = 54
    
    var body: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 20)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            

            
            contentSection
                .padding(.top, 30)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .onAppear(perform: animateContent)
        .navigationDestination(isPresented: $showStoryView) {
            StoryViewScreen()
        }
        .navigationDestination(isPresented: $showStoryCreator) {
            StoryCreatorScreen()
        }
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
    

    
    private var contentSection: some View {
        Group {
            if stories.isEmpty {
                emptyStateView
            } else {
                storiesListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("icon_8")
                .resizable()
                .frame(width: 100, height: 100)
                .opacity(0.8)
            
            VStack(spacing: 12) {
                Text("no_stories_title".localized)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.titleGradient)
                    .multilineTextAlignment(.center)
                
                Text("no_stories_subtitle".localized)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.subtleText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                showStoryCreator = true
            }) {
                Text("create_story".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .background(AppColors.contrastPrimary)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppColors.primaryBorder, lineWidth: 2)
                    )
                    .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, horizontalPadding)
            
            Spacer()
        }
    }
    
    private var storiesListView: some View {
        List {
            ForEach(stories) { story in
                storyCard(story)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: cardSpacing/2, leading: horizontalPadding, bottom: cardSpacing/2, trailing: horizontalPadding))
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
                // Header
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(story.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.darkText)
                            .lineLimit(1)
                        
                        Text("hero_prefix".localized(story.heroName))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.fairyPurple)
                    }
                    
                    Spacer()
                    
                    Text(story.dateCreated, style: .date)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.subtleText)
                }
                
                // Preview
                Text(story.preview)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundColor(AppColors.subtleText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                

            }
            .padding(20)
            .background(AppColors.cloudWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private func animateContent() {
        // Анимация заголовка
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.6)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
            }
        }
        
        // Анимация контента с задержкой
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.8)) {
                    contentOpacity = 1.0
                    contentOffset = 0.0
                }
            }
        }
    }
    
    private func deleteStory(_ story: Story) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = stories.firstIndex(where: { $0.id == story.id }) {
                stories.remove(at: index)
            }
        }
    }
}

#Preview {
    MyStoriesScreen()
} 
