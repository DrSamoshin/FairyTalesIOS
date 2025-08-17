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
    
    var body: some View {
        NavigationView {
            SubscriptionStoreView(groupID: "21757017") {
                subscriptionHeader
            }
            .backgroundStyle(.clear)
            .subscriptionStoreButtonLabel(.multiline)
            .subscriptionStorePickerItemBackground(.thickMaterial)
            .storeButton(.visible, for: .restorePurchases)
            .navigationTitle("subscription_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Debug") {
                        isDebugging.toggle()
                        performDiagnostics()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
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
        VStack(spacing: 24) {
            // App Icon
            Image("icon_7")
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Title and Subtitle
            VStack(spacing: 12) {
                Text("subscription_title".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("subscription_subtitle".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 16) {
                featureRow(icon: "wand.and.stars", text: "subscription_feature_unlimited".localized)
                featureRow(icon: "person.2.fill", text: "subscription_feature_personalized".localized)
                featureRow(icon: "globe", text: "subscription_feature_multilingual".localized)
                featureRow(icon: "clock.fill", text: "subscription_feature_instant".localized)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    SubscriptionScreen()
}
