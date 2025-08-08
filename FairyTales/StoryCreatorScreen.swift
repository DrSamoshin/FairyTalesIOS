//
//  StoryCreatorScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct StoryCreatorScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var storyName = ""
    @State private var heroName = ""
    @State private var age = 5
    @State private var idea = ""
    @State private var selectedStyle = "Adventure"
    @State private var selectedLanguage: SupportedLanguage = .english
    @State private var isLoading = false
    @State private var showStoryView = false

    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var formOpacity: Double = 0.0
    @State private var formOffset: CGFloat = 20.0
    
    private let horizontalPadding: CGFloat = 30

    private let buttonHeight: CGFloat = 54
    private let animationDuration: Double = 0.15
    private let cornerRadius: CGFloat = 16
    
    let styles = ["Adventure", "Fantasy", "Comedy", "Educational", "Mystery"]
    
    var body: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 20)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            
            ScrollView {
                VStack(spacing: 10) {
                    Spacer(minLength: 30)
                    titleSection
                    Spacer(minLength: 20)
                    storyForm
                    Spacer(minLength: 10)
                    actionButtons
                    Spacer(minLength: 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .onTapGesture(perform: hideKeyboard)
        .onAppear(perform: animateContent)
        .navigationDestination(isPresented: $showStoryView) {
            StoryViewScreen()
        }
    }
    
    private var backButton: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("back".localized)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            titleTexts
        }
    }
    

    
    private var titleTexts: some View {
        VStack(spacing: 8) {
            Text("create_story_title".localized)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            
            Text("story_creator_subtitle".localized)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
    }
    
    private var storyForm: some View {
        VStack(spacing: 20) {
            formField(label: "story_name_label".localized, placeholder: "story_name_placeholder".localized, text: $storyName)
            formField(label: "hero_name_label".localized, placeholder: "hero_name_placeholder".localized, text: $heroName)
            ageField
            styleField
            languageField
            ideaField
        }
        .padding(.horizontal, horizontalPadding)
        .opacity(formOpacity)
        .offset(y: formOffset)
    }
    
    private func formField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 16, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                TextField("", text: text)
                    .foregroundColor(AppColors.darkText)
                    .font(.system(size: 16, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(AppColors.cloudWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var ageField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("age_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            HStack {
                Stepper(value: $age, in: 3...12) {
                    Text("age_format".localized(age))
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppColors.darkText)
                }
                .tint(AppColors.darkText)
            }
            .frame(height: 20)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.cloudWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var styleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("story_style_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Picker("Style", selection: $selectedStyle) {
                ForEach(styles, id: \.self) { style in
                    Text(style.lowercased().localized)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppColors.darkText)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(AppColors.darkText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 20)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.cloudWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var languageField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("language_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Picker("Language", selection: $selectedLanguage) {
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Text(language.displayName)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppColors.darkText)
                        .tag(language)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(AppColors.darkText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 20)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.cloudWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var ideaField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("story_idea_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                if idea.isEmpty {
                    Text("story_idea_placeholder".localized)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 16, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                }
                TextEditor(text: $idea)
                    .foregroundColor(AppColors.darkText)
                    .font(.system(size: 16, design: .rounded))
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(AppColors.cloudWhite)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 15) {
            // Generate Button
            Button(action: generateStory) {
                Text(isLoading ? "creating_magic".localized : "generate_story".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.primaryBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
            }
            .disabled(isLoading)
        }
        .padding(.horizontal, horizontalPadding)
        .opacity(formOpacity)
        .offset(y: formOffset)
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("background_5")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.softWhite.opacity(0.1),
                    AppColors.cloudWhite.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    

    
    private func animateContent() {
        // Анимация заголовка
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.6)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
            }
        }
        
        // Анимация формы с задержкой
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.8)) {
                    formOpacity = 1.0
                    formOffset = 0.0
                }
            }
        }
        
        // Устанавливаем текущий язык приложения по умолчанию
        selectedLanguage = localizationManager.currentLanguage
    }
    
    private func generateStory() {
        isLoading = true
        // Заглушка для POST /generate
        print("Generating story...")
        print("Story: \(storyName), Hero: \(heroName), Age: \(age)")
        print("Style: \(selectedStyle), Language: \(selectedLanguage.displayName)")
        print("Idea: \(idea)")
        
        // Имитация загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            showStoryView = true
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    StoryCreatorScreen()
} 
