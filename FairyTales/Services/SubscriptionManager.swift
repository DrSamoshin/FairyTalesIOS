//
//  SubscriptionManager.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import StoreKit
import Observation
import UIKit

@Observable
@MainActor
final class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    var hasActiveSubscription = false
    var isLoading = false
    var errorMessage: String?
    
    private let subscriptionGroupID = "21757017"
    private var lastCheckDate: Date?
    private let cacheValidityPeriod: TimeInterval = 300 // 5 minutes
    
    private init() {
        // Don't check subscription in init to avoid blocking UI
        // Initialize status check on first access or app became active
        setupNotificationObservers()
        setupTransactionObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.checkSubscriptionStatusIfNeeded()
            }
        }
    }
    
    private func setupTransactionObserver() {
        Task {
            // Listen for transaction updates
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    // Transaction update received for product: \(transaction.productID)
                    
                    // If it's a subscription transaction, refresh status
                    if transaction.productType == .autoRenewable {
                        await performSubscriptionCheck()
                        
                        // Notify about purchase completion
                        NotificationCenter.default.post(name: Notification.Name("InAppPurchaseCompleted"), object: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Subscription Status Check
    func checkSubscriptionStatus() async {
        await performSubscriptionCheck()
    }
    
    func checkSubscriptionStatusIfNeeded() async {
        // Check if we need to refresh based on cache validity
        if shouldRefreshSubscriptionStatus() {
            await performSubscriptionCheck()
        }
    }
    
    private func shouldRefreshSubscriptionStatus() -> Bool {
        guard let lastCheck = lastCheckDate else { return true }
        return Date().timeIntervalSince(lastCheck) > cacheValidityPeriod
    }
    
    private func performSubscriptionCheck() async {
        isLoading = true
        errorMessage = nil
        
        let previousStatus = hasActiveSubscription
        
        // Use standard Apple method to check subscription status
        // This checks all current entitlements for the app
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Check if this is an auto-renewable subscription
                if transaction.productType == .autoRenewable {
                    // Verify the subscription is still active
                    if transaction.revocationDate == nil {
                        hasActiveSubscription = true
                        lastCheckDate = Date()
                        isLoading = false
                        
                        // Notify if status changed
                        if previousStatus != hasActiveSubscription {
                            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
                        }
                        return
                    }
                }
            }
        }
        
        // No active subscription found
        hasActiveSubscription = false
        lastCheckDate = Date()
        
        // Notify if status changed
        if previousStatus != hasActiveSubscription {
            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        }
        
        isLoading = false
    }
    
    // MARK: - Public Methods
    func refreshSubscriptionStatus() async {
        await performSubscriptionCheck()
    }
    
    func requiresSubscription() -> Bool {
        // For now, require subscription for story creation and viewing
        // This can be made configurable later
        return true
    }
    
    func canCreateStory() -> Bool {
        return hasActiveSubscription
    }
    
    func canViewStories() -> Bool {
        return hasActiveSubscription
    }
    
    func canAccessPremiumFeatures() -> Bool {
        return hasActiveSubscription
    }
    
    // MARK: - Initial Check
    func performInitialCheckIfNeeded() async {
        if lastCheckDate == nil {
            await performSubscriptionCheck()
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}
