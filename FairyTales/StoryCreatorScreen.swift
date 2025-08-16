//
//  StoryCreatorScreen.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import SwiftUI

struct StoryCreatorScreen: View {
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var storyService = StoryService.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Form data
    @State private var storyName = ""
    @State private var heroName = ""
    @State private var age = 5
    @State private var childGender = "boy"
    @State private var storyLength = 3
    @State private var idea = ""
    @State private var selectedStyle = "Adventure"
    @State private var selectedLanguage: SupportedLanguage = .english
    
    // Navigation
    @State private var showStoryView = false
    @State private var showStreamingView = false
    @State private var showingAlert = false
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var formOpacity: Double = 0.0
    @State private var formOffset: CGFloat = 20.0
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let buttonHeight: CGFloat = 54
        static let cornerRadius: CGFloat = 16
        static let titleAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let formAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let titleAnimationDuration: Double = 0.6
        static let formAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 10
        static let formSpacing: CGFloat = 20
        static let fieldSpacing: CGFloat = 8
        
        static let styles = ["Adventure", "Fantasy", "Educational", "Mystery"]
        static let genders = ["boy", "girl"]
    }
    
    private var isTimeoutError: Bool {
        return storyService.errorMessage?.contains("story_timeout_message".localized) == true ||
               storyService.errorMessage?.contains("timeout_error_occurred".localized) == true
    }
    
    var body: some View {
        NavigationStack {
            storyCreatorContent
        }
        .alert(isTimeoutError ? "story_timeout_title".localized : "Error", isPresented: $showingAlert) {
            alertButtons
        } message: {
            Text(storyService.errorMessage ?? "Unknown error")
        }
        .onChange(of: storyService.errorMessage) { _, newError in
            showingAlert = newError != nil
        }
        .navigationDestination(isPresented: $showStoryView) {
            if let story = storyService.currentStory {
                StoryViewScreen(story: story)
            }
        }
        .navigationDestination(isPresented: $showStreamingView) {
            StoryStreamingScreen(storyData: createStoryGenerateRequest())
        }
    }
    
    // MARK: - Main Content
    private var storyCreatorContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.contentPadding)
                .padding(.top, 20)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            scrollableForm
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
        .navigationBarHidden(true)
        .onTapGesture(perform: hideKeyboard)
        .onAppear(perform: startAnimations)
    }
    
    private var scrollableForm: some View {
        ScrollView {
            VStack(spacing: Constants.vStackSpacing) {
                Spacer(minLength: 30)
                titleSection
                Spacer(minLength: 20)
                storyForm
                Spacer(minLength: 10)
                actionButtons
                Spacer(minLength: 30)
            }
        }
        .scrollFadeEffect(fadeHeight: 25, direction: .top)
    }
    
    @ViewBuilder
    private var alertButtons: some View {
        if isTimeoutError {
            Button("check_stories_later".localized) {
                storyService.errorMessage = nil
                presentationMode.wrappedValue.dismiss()
            }
            Button("OK") {
                storyService.errorMessage = nil
            }
        } else {
            Button("OK") {
                storyService.errorMessage = nil
            }
        }
    }
    
    // MARK: - Header Components
    private var backButton: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.appBackIcon)
                        .foregroundColor(.white)
                    
                    Text("back".localized)
                        .font(.appBackText)
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
                .font(.appH1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            Text("story_creator_subtitle".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    // MARK: - Form Components
    private var storyForm: some View {
        VStack(spacing: Constants.formSpacing) {
            formField(label: "story_name_label".localized, placeholder: "story_name_placeholder".localized, text: $storyName)
            formField(label: "hero_name_label".localized, placeholder: "hero_name_placeholder".localized, text: $heroName)
            ageField
            genderField
            styleField
            languageField
            ideaField
            storyLengthField
        }
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: formOpacity, offset: formOffset)
    }
    
    private func formField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text(label)
                .font(.appLabel)
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color.gray)
                        .font(.appInputField)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                TextField("", text: text)
                    .foregroundColor(AppColors.darkText)
                    .font(.appInputField)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var ageField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("age_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text("age_format".localized(age))
                        .font(.appLabel)
                        .foregroundColor(AppColors.darkText)
                    Spacer()
                }
                
                Slider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0.rounded()) }
                ), in: 3...12, step: 1)
                .tint(AppColors.contrastPrimary.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var genderField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("child_gender_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(Constants.genders, id: \.self) { gender in
                    genderButton(for: gender)
                }
            }
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private func genderButton(for gender: String) -> some View {
        Button(action: {
            childGender = gender
        }) {
            genderButtonContent(for: gender)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func genderButtonContent(for gender: String) -> some View {
        let isSelected = childGender == gender
        
        return HStack(spacing: 8) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .white : .gray)
                .font(.appBody)
            
            Text(gender.localized)
                .font(.appLabelMedium)
                .foregroundColor(isSelected ? .white : AppColors.darkText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(backgroundForGenderButton(isSelected: isSelected, gender: gender))
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(strokeColorForGenderButton(isSelected: isSelected), lineWidth: 2)
        )
    }
    
    @ViewBuilder
    private func backgroundForGenderButton(isSelected: Bool, gender: String) -> some View {
        if isSelected {
            if gender == "boy" {
                AppColors.contrastSecondary
            } else {
                AppColors.contrastPrimary
            }
        } else {
            AppColors.fieldGradient
        }
    }
    
    private func strokeColorForGenderButton(isSelected: Bool) -> Color {
        return isSelected ? Color.white : Color.white.opacity(0.5)
    }
    
    private var styleField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("story_style_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(Constants.styles, id: \.self) { style in
                    Button(action: {
                        selectedStyle = style
                    }) {
                        Text(style.lowercased().localized)
                            .font(.appCaption)
                            .foregroundColor(selectedStyle == style ? .white : AppColors.darkText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedStyle == style ? AppColors.contrastPrimary : AppColors.fieldGradient)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedStyle == style ? Color.white : Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.fieldGradient.opacity(0.3))
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var languageField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("language_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                    }) {
                        Text(language.shortName)
                            .font(.appCaptionSemibold)
                            .foregroundColor(selectedLanguage == language ? .white : AppColors.darkText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedLanguage == language ? AppColors.contrastSecondary : AppColors.fieldGradient)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedLanguage == language ? Color.white : Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.fieldGradient.opacity(0.3))
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var ideaField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("story_idea_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                if idea.isEmpty {
                    Text("story_idea_placeholder".localized)
                        .foregroundColor(Color.gray)
                        .font(.appInputField)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                }
                TextEditor(text: $idea)
                    .foregroundColor(AppColors.darkText)
                    .font(.appInputField)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var storyLengthField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("story_length_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text(getLengthDescription(for: storyLength))
                        .font(.appLabel)
                        .foregroundColor(AppColors.darkText)
                    Spacer()
                }
                
                Slider(value: Binding(
                    get: { Double(storyLength) },
                    set: { storyLength = Int($0.rounded()) }
                ), in: 1...5, step: 1)
                .tint(AppColors.contrastPrimary.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private func getLengthDescription(for length: Int) -> String {
        switch length {
        case 1: return "story_length_very_short".localized
        case 2: return "story_length_short".localized
        case 3: return "story_length_medium".localized
        case 4: return "story_length_long".localized
        case 5: return "story_length_very_long".localized
        default: return "story_length_medium".localized
        }
    }
    
    // MARK: - Action Components
    private var actionButtons: some View {
        Button(action: generateStory) {
            Text("generate_story".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Color(red: 0.95, green: 0.75, blue: 0.85), lineWidth: 2)
                )
        }
        .disabled(storyName.isEmpty || heroName.isEmpty || idea.isEmpty)
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: formOpacity, offset: formOffset)
    }
    
    // MARK: - Background
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
    
    // MARK: - Animation Methods
    private func startAnimations() {
        animateTitle()
        animateForm()
        setDefaultLanguage()
    }
    
    private func animateTitle() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.titleAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.titleAnimationDuration)) {
                    titleOpacity = 1.0
                    titleOffset = 0.0
                }
            }
        }
    }
    
    private func animateForm() {
        Task {
            try? await Task.sleep(nanoseconds: Constants.formAnimationDelay)
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.formAnimationDuration)) {
                    formOpacity = 1.0
                    formOffset = 0.0
                }
            }
        }
    }
    
    private func setDefaultLanguage() {
        selectedLanguage = localizationManager.currentLanguage
    }
    
    // MARK: - Helper Methods
    private func generateStory() {
        print("🎭 Starting story generation with streaming...")
        print("📝 Story: \(storyName), Hero: \(heroName), Age: \(age)")
        print("👤 Gender: \(childGender)")
        print("🎨 Style: \(selectedStyle), Language: \(selectedLanguage.rawValue)")
        print("📏 Length: \(storyLength) - \(getLengthDescription(for: storyLength))")
        print("💡 Idea: \(idea)")
        
        showStreamingView = true
    }
    
    private func createStoryGenerateRequest() -> StoryGenerateRequest {
        return storyService.createStoryRequest(
            storyName: storyName,
            heroName: heroName,
            storyIdea: idea,
            storyStyle: selectedStyle,
            language: selectedLanguage.rawValue,
            age: age,
            storyLength: storyLength,
            childGender: childGender
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - View Extensions
private extension View {
    func animatedContent(opacity: Double, offset: CGFloat) -> some View {
        self
            .opacity(opacity)
            .offset(y: offset)
    }
}

#Preview {
    StoryCreatorScreen()
}