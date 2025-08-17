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
    @State private var isDebugging = false
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 30.0
    
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
                    
                    // Subscription button
                    SubscriptionStoreView(groupID: "21757017") {
                        EmptyView()
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Debug") {
                            isDebugging.toggle()
                            performDiagnostics()
                        }
                        .foregroundColor(.white)
                    }
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
        .alert("StoreKit Diagnostics", isPresented: $isDebugging) {
            Button("OK") { }
        } message: {
            Text("Check console for detailed diagnostic information")
        }
    }
    
    private func performDiagnostics() {
        Task {
            print("=== STOREKIT DIAGNOSTICS ===")
            print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
            print("Team ID: \(Bundle.main.object(forInfoDictionaryKey: "TeamIdentifierPrefix") ?? "Unknown")")
            print("Group ID: 21757017")
            print("Store environment: \(AppStore.canMakePayments ? "Can make payments" : "Cannot make payments")")
            
            // Test different possible product IDs
            let possibleProductIDs = [
                "fairy_tales_basic_monthly",
                "fairy_tales_monthly", 
                "fairy.tales.basic.monthly",
                "fairytales_basic_monthly",
                "premium_monthly"
            ]
            
            print("Testing possible product IDs...")
            for productID in possibleProductIDs {
                do {
                    print("  Testing: \(productID)")
                    let products = try await Product.products(for: [productID])
                    if !products.isEmpty {
                        print("    SUCCESS: Found \(products.count) product(s) for \(productID)")
                        for product in products {
                            print("      - ID: \(product.id)")
                            print("      - Name: \(product.displayName)")
                            print("      - Price: \(product.displayPrice)")
                            if let subscription = product.subscription {
                                print("      - Group: \(subscription.subscriptionGroupID)")
                                print("      - Period: \(subscription.subscriptionPeriod)")
                            }
                        }
                    } else {
                        print("    No products found for \(productID)")
                    }
                } catch {
                    print("    Error loading \(productID): \(error)")
                }
            }
            
            // Also try to load ALL available products
            print("\nAttempting to discover all available products...")
            do {
                // Try loading products with empty array to see what's available
                let allProducts = try await Product.products(for: [])
                print("Available products: \(allProducts.count)")
                for product in allProducts {
                    print("  - \(product.id): \(product.displayName)")
                }
            } catch {
                print("Error loading all products: \(error)")
            }
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
