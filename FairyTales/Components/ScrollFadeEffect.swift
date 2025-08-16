//
//  ScrollFadeEffect.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

// MARK: - Scroll Fade Effect Component
struct ScrollFadeEffect: View {
    let fadeHeight: CGFloat
    let direction: FadeDirection
    
    enum FadeDirection {
        case top
        case bottom
        case both
    }
    
    init(fadeHeight: CGFloat = 20, direction: FadeDirection = .top) {
        self.fadeHeight = fadeHeight
        self.direction = direction
    }
    
    var body: some View {
        switch direction {
        case .top:
            topFadeGradient
        case .bottom:
            bottomFadeGradient
        case .both:
            bothFadeGradient
        }
    }
    
    private var topFadeGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black, location: fadeStopLocation),
                .init(color: .black, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var bottomFadeGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .black, location: 0.0),
                .init(color: .black, location: 1.0 - fadeStopLocation),
                .init(color: .clear, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var bothFadeGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black, location: fadeStopLocation),
                .init(color: .black, location: 1.0 - fadeStopLocation),
                .init(color: .clear, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var fadeStopLocation: CGFloat {
        // Преобразуем fadeHeight в процент от экрана
        // Для fadeHeight = 20 при высоте экрана ~800 = 0.025 (2.5%)
        min(fadeHeight / UIScreen.main.bounds.height, 0.1) // Максимум 10%
    }
}

// MARK: - View Extension
extension View {
    /// Применяет эффект затухания к скроллируемому контенту
    func scrollFadeEffect(
        fadeHeight: CGFloat = 20,
        direction: ScrollFadeEffect.FadeDirection = .top
    ) -> some View {
        self.mask(
            ScrollFadeEffect(fadeHeight: fadeHeight, direction: direction)
        )
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(0..<20) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: 60)
                    .overlay(
                        Text("Item \(index + 1)")
                            .foregroundColor(.white)
                            .font(.appSubtitle)
                    )
            }
        }
        .padding()
    }
    .scrollFadeEffect(fadeHeight: 30, direction: .both)
    .background(Color.gray.opacity(0.1))
}
