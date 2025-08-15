//
//  FairyTalesApp.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI
import UIKit

@main
struct FairyTalesApp: App {
    @State private var authManager = AuthManager.shared
    @State private var healthCheckManager = HealthCheckManager.shared
    
    init() {
        print("🚀🚀🚀 FAIRYTALES APP STARTING 🚀🚀🚀")
        print("📱 Device: iOS \(UIDevice.current.systemVersion)")
        print("⚡️ Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager.shared)
                .environment(authManager)
                .environment(healthCheckManager)
                .preferredColorScheme(.dark) // Принудительно темная тема
        }
    }
}

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(HealthCheckManager.self) private var healthCheckManager
    @State private var hasPerformedInitialHealthCheck = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainScreen()
            } else {
                AuthScreen()
            }
        }
        .onAppear {
            print("📺📺📺 CONTENTVIEW APPEARED 📺📺📺")
            print("🔐 Authenticated: \(authManager.isAuthenticated)")
            print("🏥 Server Available: \(healthCheckManager.isServerAvailable)")
            if !hasPerformedInitialHealthCheck {
                print("FairyTalesApp: ContentView appeared, starting initial health check...")
                hasPerformedInitialHealthCheck = true
                Task {
                    print("FairyTalesApp: About to call performHealthCheckWithRetry...")
                    await healthCheckManager.performHealthCheckWithRetry()
                    print("FairyTalesApp: Health check completed in ContentView")
                }
            } else {
                print("FairyTalesApp: ContentView appeared but health check already performed")
            }
        }
        .alert("server_health_error_title".localized, isPresented: .constant(!healthCheckManager.isServerAvailable && !healthCheckManager.isCheckingHealth)) {
            Button("retry_connection".localized) {
                print("FairyTalesApp: User requested retry connection")
                Task {
                    await healthCheckManager.performHealthCheckWithRetry()
                }
            }
            Button("continue_offline".localized) {
                print("FairyTalesApp: User chose to continue offline")
                // Allow user to continue without server
                healthCheckManager.resetHealthStatus()
            }
        } message: {
            Text(healthCheckManager.serverErrorMessage ?? "server_unavailable".localized)
        }
    }
}
