//
//  StoryConfirmationModal.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI
import StoreKit

struct StoryConfirmationModal: View {
    @Binding var isPresented: Bool
    let storyId: String?
    let storyService: StoryService
    let onReturn: () -> Void
    

    
    // MARK: - Constants
    private let cornerRadius: CGFloat = 16
    
    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                
                VStack(spacing: 20) {
                    Text("story_saved_title".localized)
                        .font(.appH2)
                        .foregroundColor(AppColors.darkText)
                        .multilineTextAlignment(.center)
                    
                    Text("story_saved_message".localized)
                        .font(.appLabelMedium)
                        .foregroundColor(AppColors.darkText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 15) {
                        // Return Button
                        Button(action: {
                            // Request rating after story completion
                            requestAppStoreRating()
                            
                            isPresented = false
                            onReturn()
                        }) {
                            Text("return_back".localized)
                                .font(.appSubtitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.3),  // Темно-зеленый
                                            Color(red: 0.3, green: 0.9, blue: 0.6)   // Яркий светло-зеленый
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color(red: 0.0, green: 0.4, blue: 0.2), lineWidth: 2)
                                )
                                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
                        }
                        
                        // Delete Button - only show if story is saved
                        if let storyId = storyId {
                            Button(action: {
                                Task {
                                    let success = await storyService.deleteStory(storyId: storyId)
                                    if success {
                                        print("Story deleted successfully")
                                    } else {
                                        print("Failed to delete story")
                                    }
                                    
                                    // В любом случае возвращаемся назад
                                    isPresented = false
                                    onReturn()
                                }
                            }) {
                                HStack {
                                    if storyService.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    }
                                    Text("delete_story".localized)
                                        .font(.appSubtitle)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.3, blue: 0.3),  // Красный
                                            Color(red: 1.0, green: 0.6, blue: 0.2)   // Оранжевый
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color(red: 0.8, green: 0.2, blue: 0.2), lineWidth: 2)
                                )
                                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
                            }
                            .disabled(storyService.isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(30)
                .background(AppColors.cloudWhite)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: AppColors.mediumShadow, radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40)
                .scaleEffect(isPresented ? 1.0 : 0.8)
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
            }
        }
    }
    
    // MARK: - Rating Helper
    private func requestAppStoreRating() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: windowScene)
            } else {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}

#Preview {
    StoryConfirmationModal(
        isPresented: .constant(true),
        storyId: "test-id",
        storyService: StoryService.shared,
        onReturn: {}
    )
}
