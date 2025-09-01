//
//  FairyTalesApp.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI
import UIKit
import StoreKit

@main
struct FairyTalesApp: App {
    @State private var authManager = AuthManager.shared
    @State private var healthCheckManager = HealthCheckManager.shared
    @State private var subscriptionManager = SubscriptionManager.shared
    
    init() {
        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: "app_launch_count") + 1,
            forKey: "app_launch_count"
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager.shared)
                .environment(authManager)
                .environment(healthCheckManager)
                .environment(subscriptionManager)
                .preferredColorScheme(.dark) // Принудительно темная тема
        }
    }
}

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(HealthCheckManager.self) private var healthCheckManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var hasPerformedInitialHealthCheck = false
    @State private var heroService = HeroService.shared
    @State private var storyService = StoryService.shared
    @State private var showOnboarding = false
    @State private var hasCheckedOnboarding = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if showOnboarding {
                    OnboardingFlowView(onComplete: {
                        showOnboarding = false
                    })
                } else {
                    MainScreen()
                }
            } else {
                AuthScreen()
            }
        }
        .onAppear {
            if !hasPerformedInitialHealthCheck {
                hasPerformedInitialHealthCheck = true
                Task {
                    await healthCheckManager.performHealthCheckWithRetry()
                    await subscriptionManager.performInitialCheckIfNeeded()
                    
                    if authManager.isAuthenticated && healthCheckManager.isServerAvailable {
                        requestAppStoreRating()
                        await checkOnboardingStatus()
                    }
                }
            }
        }
        .alert("server_health_error_title".localized, isPresented: .constant(!healthCheckManager.isServerAvailable && !healthCheckManager.isCheckingHealth)) {
            Button("retry_connection".localized) {
                Task {
                    await healthCheckManager.performHealthCheckWithRetry()
                }
            }
            Button("continue_offline".localized) {
                healthCheckManager.resetHealthStatus()
            }
        } message: {
            Text(healthCheckManager.serverErrorMessage ?? "server_unavailable".localized)
        }
    }
    
    // MARK: - Onboarding Helper
    private func checkOnboardingStatus() async {
        guard !hasCheckedOnboarding else { return }
        hasCheckedOnboarding = true
        
        let userHeroes = await heroService.fetchUserHeroes()
        let userStories = await storyService.fetchUserStories()
        
        await MainActor.run {
            // Показываем онбординг только если нет И героев, И историй одновременно
            showOnboarding = userHeroes.isEmpty && userStories.isEmpty
        }
    }
    
    // MARK: - Rating Helper
    private func requestAppStoreRating() {
        let launchCount = UserDefaults.standard.integer(forKey: "app_launch_count")
        
        // Request rating after 5+ launches and positive interaction
        if launchCount >= 5 {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if #available(iOS 18.0, *) {
                    AppStore.requestReview(in: windowScene)
                } else {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
            }
        }
    }
}
