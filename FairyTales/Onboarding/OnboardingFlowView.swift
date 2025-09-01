//
//  OnboardingFlowView.swift
//  FairyTales
//
//  Created by Assistant on 01/09/2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    // MARK: - Properties
    let onComplete: () -> Void
    
    // MARK: - State
    @State private var navigationPath = NavigationPath()
    @State private var storyRequest: StoryGenerateRequest?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            OnboardingScreen1(
                onNext: {
                    navigationPath.append(OnboardingStep.storySetup)
                },
                onSkip: onComplete
            )
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .storySetup:
                    OnboardingScreen2(
                        onNext: {
                            navigationPath.append(OnboardingStep.storyStreaming)
                        },
                        onSkip: onComplete,
                        onStoryGenerated: { request in
                            storyRequest = request
                        }
                    )
                case .storyStreaming:
                    OnboardingScreen3(
                        onNext: onComplete,
                        onSkip: onComplete,
                        storyRequest: storyRequest
                    )
                }
            }
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToHeroCreation"))) { _ in
                // Возврат на первый экран
                navigationPath = NavigationPath()
            }
        }
    }
}

// MARK: - Navigation Steps
enum OnboardingStep: Hashable {
    case storySetup
    case storyStreaming
}

#Preview {
    OnboardingFlowView(
        onComplete: { print("Onboarding completed") }
    )
}