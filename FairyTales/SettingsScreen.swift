//
//  SettingsScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingLogoutAlert = false
    @State private var userEmail = "user@example.com"
    
    var body: some View {
        List {
            // Profile Section
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("user_profile".localized)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text(userEmail)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // App Settings Section
            Section("app_settings".localized) {
                // Language Setting
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .frame(width: 25)
                    
                    Text("language_setting".localized)
                        .font(.system(size: 16, design: .rounded))
                    
                    Spacer()
                    
                    Picker("Language", selection: $localizationManager.currentLanguage) {
                        ForEach(SupportedLanguage.allCases, id: \.self) { language in
                            Text(language.nativeName)
                                .font(.system(size: 16, design: .rounded))
                                .tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: localizationManager.currentLanguage) { _, newLanguage in
                        localizationManager.setLanguage(newLanguage)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Legal Section
            Section("legal".localized) {
                // Privacy Policy
                Button(action: {
                    print("Privacy Policy tapped")
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.green)
                            .frame(width: 25)
                        
                        Text("privacy_policy".localized)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Terms of Service
                Button(action: {
                    print("Terms of Service tapped")
                }) {
                    HStack {
                        Image(systemName: "doc.plaintext")
                            .foregroundColor(.green)
                            .frame(width: 25)
                        
                        Text("terms_of_service".localized)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Account Section
            Section("account".localized) {
                // Show Email (toggle-like display)
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.orange)
                        .frame(width: 25)
                    
                    Text("email_setting".localized)
                        .font(.system(size: 16, design: .rounded))
                    
                    Spacer()
                    
                    Text(userEmail)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                // Logout
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .frame(width: 25)
                        
                        Text("logout".localized)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .alert("logout".localized, isPresented: $showingLogoutAlert) {
                    Button("logout".localized, role: .destructive) {
                        print("User logged out")
                    }
                    Button("cancel".localized, role: .cancel) { }
                } message: {
                    Text("logout_confirmation".localized)
                }
            }
        }
        .navigationTitle("settings_title".localized)
        .navigationBarTitleDisplayMode(.large)
        .background(
            ZStack {
                Image("background_5")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        )
    }
}

#Preview {
    NavigationView {
        SettingsScreen()
    }
} 