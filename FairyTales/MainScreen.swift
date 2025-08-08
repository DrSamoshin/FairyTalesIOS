
//
//  MainScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var iconScale: CGFloat = 1.0
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var buttonsOffset: CGFloat = 20.0
    
    private let horizontalPadding: CGFloat = 30
    private let buttonHeight: CGFloat = 70
    private let settingsButtonHeight: CGFloat = 54
    private let cornerRadius: CGFloat = 16
    private let iconSize: CGFloat = 100
    private let animationDuration: Double = 0.15
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                titleSection
                Spacer()
                mainButtons
                Spacer()
                settingsButton
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 30)
                    .opacity(buttonsOpacity)
                    .offset(y: buttonsOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundView)
            .onAppear(perform: animateContent)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            animatedIcon
            titleTexts
        }
    }
    
    private var animatedIcon: some View {
        Button(action: animateIcon) {
            Image("icon_7")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .scaleEffect(iconScale)
        }
    }
    
    private var titleTexts: some View {
        VStack(spacing: 8) {
            Text("main_title".localized)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.titleGradient)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            
            Text("main_subtitle".localized)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.subtleText)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
    }
    
    private var mainButtons: some View {
        VStack(spacing: 20) {
            createNewStoryButton
            myStoriesButton
        }
        .padding(.horizontal, horizontalPadding)
        .opacity(buttonsOpacity)
        .offset(y: buttonsOffset)
    }
    
    private var createNewStoryButton: some View {
        NavigationLink(destination: StoryCreatorScreen()) {
            HStack(spacing: 20) {
                Image("icon_3")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("create_new_story".localized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("create_story_subtitle".localized)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(AppColors.contrastPrimary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.primaryBorder, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
    }
    
    private var myStoriesButton: some View {
        NavigationLink(destination: MyStoriesScreen()) {
            HStack(spacing: 20) {
                Image("icon_2")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("my_stories".localized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.1, blue: 0.5))
                    Text("my_stories_subtitle".localized)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.1, blue: 0.5).opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.1, blue: 0.5).opacity(0.7))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.7),  // Пастельный персиковый
                        Color(red: 1.0, green: 0.95, blue: 0.8)   // Пастельный кремово-желтый
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1.0, green: 0.98, blue: 0.85), lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
    }
    
    private var settingsButton: some View {
        NavigationLink(destination: SettingsScreen()) {
            Text("settings".localized)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: settingsButtonHeight)
                .background(Color.clear)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("background_3")
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
        
        // Анимация кнопок с задержкой
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
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
     MainScreen()
 } 
