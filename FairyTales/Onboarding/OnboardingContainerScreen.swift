//
//  OnboardingContainerScreen.swift
//  FairyTales
//
//  Created by Assistant on 31/08/2025.
//

import SwiftUI

struct OnboardingContainerScreen: View {
    // MARK: - Properties
    let onComplete: () -> Void
    
    // MARK: - State
    @State private var currentPage = 0
    @State private var storyRequest: StoryGenerateRequest?
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingScreen1(
                onNext: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 1
                    }
                },
                onSkip: onComplete
            )
            .tag(0)
            
            OnboardingScreen2(
                onNext: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 2
                    }
                },
                onSkip: onComplete,
                onStoryGenerated: { request in
                    storyRequest = request
                }
            )
            .tag(1)
            
            OnboardingScreen3(
                onNext: onComplete,
                onSkip: onComplete,
                storyRequest: storyRequest
            )
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToHeroCreation"))) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage = 0
            }
        }
    }
}

#Preview {
    OnboardingContainerScreen(
        onComplete: { print("Onboarding completed") }
    )
}