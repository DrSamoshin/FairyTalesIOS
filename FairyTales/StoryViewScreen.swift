//
//  StoryViewScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct StoryViewScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var storyManager = StoryManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEndConfirmation = false
    
    let story: Story
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    @State private var iconScale: CGFloat = 1.0
    
    private let horizontalPadding: CGFloat = 30
    private let buttonHeight: CGFloat = 54
    private let cornerRadius: CGFloat = 16
    private let iconSize: CGFloat = 80
    private let animationDuration: Double = 0.15
    

    
    var body: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 20)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            
            ScrollView {
                VStack(spacing: 10) {
                    Spacer(minLength: 30)
                    titleSection
                    Spacer(minLength: 20)
                    storyContent
                    Spacer(minLength: 10)
                    iconButton
                    Spacer(minLength: 10)
                    actionButtons
                    Spacer(minLength: 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .onAppear(perform: animateContent)
        .overlay(
            customAlert
        )
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
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            titleTexts
        }
    }
    
    private var titleTexts: some View {
        VStack(spacing: 8) {
            Text(story.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
    }
    
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(story.content)
                .font(.system(size: 18, design: .serif))
                .lineSpacing(10)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, horizontalPadding)
        }
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }
    
    private var iconButton: some View {
        Button(action: animateIcon) {
            Image("icon_6")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .scaleEffect(iconScale)
        }
        .opacity(buttonsOpacity)
        .offset(y: buttonsOffset)
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
                                .frame(height: buttonHeight)
                                .background(AppColors.contrastPrimary)
                                .cornerRadius(cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(AppColors.primaryBorder, lineWidth: 2)
                                )
                                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
                        }
                        
                        // Share Button
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
                            .frame(height: buttonHeight)
                            .background(Color.clear)
                            .cornerRadius(cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        }
        }
        .padding(.horizontal, horizontalPadding)
        .opacity(buttonsOpacity)
        .offset(y: buttonsOffset)
    }

    
    private var backgroundView: some View {
        ZStack {
            Image("background_4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var customAlert: some View {
        if showingEndConfirmation {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingEndConfirmation = false
                    }
                
                VStack(spacing: 20) {
                    Text("story_saved_title".localized)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.darkText)
                        .multilineTextAlignment(.center)
                    
                    Text("story_saved_message".localized)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 15) {
                        // Return Button
                        Button(action: {
                            showingEndConfirmation = false
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("return_back".localized)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.3),  // Темно-зеленый
                                            Color(red: 0.3, green: 0.9, blue: 0.6)   // Яркий светло-зеленый
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color(red: 0.0, green: 0.4, blue: 0.2), lineWidth: 2)
                                )
                                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
                        }
                        
                        // Delete Button
                        Button(action: {
                            Task {
                                guard let storyId = story.id else {
                                    print("❌ Story ID is missing")
                                    showingEndConfirmation = false
                                    presentationMode.wrappedValue.dismiss()
                                    return
                                }
                                
                                let success = await storyManager.deleteStory(storyId: storyId)
                                if success {
                                    print("✅ Story deleted successfully")
                                } else {
                                    print("❌ Failed to delete story")
                                }
                                
                                // В любом случае возвращаемся назад
                                showingEndConfirmation = false
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                if storyManager.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                }
                                Text("delete_story".localized)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.3, blue: 0.3),  // Красный
                                        Color(red: 1.0, green: 0.6, blue: 0.2)   // Оранжевый
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color(red: 0.8, green: 0.2, blue: 0.2), lineWidth: 2)
                            )
                            .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
                        }
                        .disabled(storyManager.isLoading)
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
                .scaleEffect(showingEndConfirmation ? 1.0 : 0.8)
                .opacity(showingEndConfirmation ? 1.0 : 0.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showingEndConfirmation)
            }
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
        
        // Анимация кнопок с задержкой
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.8)) {
                    buttonsOpacity = 1.0
                    buttonsOffset = 0.0
                }
            }
        }
    }
    
    private func animateIcon() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            iconScale = 1.15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.easeOut(duration: animationDuration)) {
                iconScale = 1.0
            }
        }
    }
}

#Preview {
    let sampleStory = Story(
        id: "1",
        title: "Luna's Magic Key",
        content: "Once upon a time, in a magical forest far, far away, there lived a brave little rabbit named Luna...",
        language: "en",
        story_style: "Adventure",
        hero_name: "Luna",
        age: 7,
        created_at: "2025-08-14T10:00:00Z"
    )
    
    return StoryViewScreen(story: sampleStory)
} 
