//
//  SubscriptionScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI
import StoreKit

struct SubscriptionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    init() {
        print("SubscriptionScreen: Initializing with Group ID: 21757017")
        print("SubscriptionScreen: Loading subscription products from App Store Connect")
        
        // Check for local StoreKit configuration
        if Bundle.main.url(forResource: "TestConf", withExtension: "storekit") != nil {
            print("LOCAL STOREKIT FILE DETECTED: TestConf.storekit")
            print("This enables testing of unpublished products from App Store Connect")
            print("For production, ensure products are published in App Store Connect")
        } else {
            print("No local StoreKit file - will load from App Store Connect")
            print("WARNING: Only published products will be available!")
        }
    }
    
    // MARK: - Constants
    private struct Constants {
        static let logoSize: CGFloat = 100
        static let cornerRadius: CGFloat = 16
        static let vStackSpacing: CGFloat = 24
        static let titleSpacing: CGFloat = 12
        static let featureSpacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 24
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundView
                
                // Content
                VStack(spacing: 0) {
                    // Header content (title, subtitle, features)
                    subscriptionHeader
                    
                    // Legal links
                    legalLinksSection
                    
                    // Info text before purchase
                    VStack(spacing: 12) {
                        Text("purchase_info".localized)
                            .font(.appCaption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.horizontalPadding)
                        
                        // Subscription button
                        SubscriptionStoreView(groupID: "21757017") {
                            EmptyView()
                        }
                    }
                    .backgroundStyle(.clear)
                    .subscriptionStoreButtonLabel(.multiline)
                    .subscriptionStorePickerItemBackground(.thickMaterial)
                    .storeButton(.visible, for: .restorePurchases)
                    .padding(.horizontal, Constants.horizontalPadding)
                    .padding(.bottom, Constants.verticalPadding)
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("done".localized) {
                            dismiss()
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            startContentAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: .subscriptionStatusChanged)) { _ in
            Task {
                await subscriptionManager.refreshSubscriptionStatus()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("InAppPurchaseCompleted"))) { _ in
            Task {
                await subscriptionManager.refreshSubscriptionStatus()
                // Auto-dismiss after successful purchase
                if subscriptionManager.hasActiveSubscription {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            LegalContentScreen(contentType: .privacyPolicy)
        }
        .sheet(isPresented: $showingTermsOfService) {
            LegalContentScreen(contentType: .termsOfService)
        }
    }
    

    
    private var subscriptionHeader: some View {
        VStack(spacing: Constants.vStackSpacing) {
            Spacer()
            
            // Title and Subtitle
            VStack(spacing: Constants.titleSpacing) {

                Text("subscription_title".localized)
                    .font(.appH1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300)
                
                Text("subscription_subtitle".localized)
                    .font(.appSubtitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320)
            }
            
            // Features List
            VStack(alignment: .center, spacing: Constants.featureSpacing) {
                featureRow(icon: "checkmark.circle.fill", text: "subscription_feature_multilingual".localized)
                featureRow(icon: "checkmark.circle.fill", text: "subscription_feature_unlimited".localized)
                featureRow(icon: "checkmark.circle.fill", text: "subscription_feature_personalized".localized)
                featureRow(icon: "checkmark.circle.fill", text: "subscription_feature_instant".localized)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .padding(.top, 2)
            
            Text(text)
                .font(.appBody)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 350)
    }
    
    private var legalLinksSection: some View {
        ViewThatFits(in: .horizontal) {
            // First try: horizontal layout
            HStack(spacing: 12) {
                Button(action: { showingPrivacyPolicy = true }) {
                    Text("privacy_policy".localized)
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                        .lineLimit(1)
                }
                
                Text("•")
                    .font(.appCaption)
                    .foregroundColor(.white.opacity(0.5))
                
                Button(action: { showingTermsOfService = true }) {
                    Text("terms_of_service".localized)
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                        .lineLimit(1)
                }
            }
            
            // Second option: vertical layout
            VStack(spacing: 8) {
                Button(action: { showingPrivacyPolicy = true }) {
                    Text("privacy_policy".localized)
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                        .lineLimit(1)
                }
                
                Button(action: { showingTermsOfService = true }) {
                    Text("terms_of_service".localized)
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: 300)
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, 16)
    }
    
    // MARK: - Animation
    private func startContentAnimation() {
        withAnimation(.easeOut(duration: 0.6)) {
            contentOpacity = 1.0
            contentOffset = 0.0
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            Image("background_16")
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
}

#Preview {
    SubscriptionScreen()
}
