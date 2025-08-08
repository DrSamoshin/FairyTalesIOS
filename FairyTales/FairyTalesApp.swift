//
//  FairyTalesApp.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

@main
struct FairyTalesApp: App {
    

    
    var body: some Scene {
        WindowGroup {
            AuthScreen()
                .environmentObject(LocalizationManager.shared)
                .preferredColorScheme(.dark) // Принудительно темная тема
        }
    }
}
