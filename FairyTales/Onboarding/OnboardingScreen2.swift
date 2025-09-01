//
//  OnboardingScreen2.swift
//  FairyTales
//
//  Created by Assistant on 31/08/2025.
//

import SwiftUI

struct OnboardingScreen2: View {
    // MARK: - Properties
    let onNext: () -> Void
    let onSkip: () -> Void
    let onStoryGenerated: (StoryGenerateRequest) -> Void
    
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var heroService = HeroService.shared
    @State private var storyName: String = ""
    @State private var selectedStyle = "Adventure"
    @State private var selectedLanguage: SupportedLanguage = .english
    @State private var userHeroes: [Hero] = []
    @State private var isCreating = false
    @State private var hasRequestSent = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var formOpacity: Double = 0.0
    @State private var formOffset: CGFloat = 20.0
    
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Computed Properties
    private var subtitleText: String {
        if userHeroes.isEmpty {
            return "You need to create your first character before creating a story"
        } else {
            return "Choose the type of magical adventure you want to experience"
        }
    }
    
    // MARK: - Constants
    private struct Constants {
        static let contentPadding: CGFloat = 30
        static let headerIconSize: CGFloat = 100
        static let textFieldHeight: CGFloat = 50
        static let textAreaHeight: CGFloat = 100
        static let buttonHeight: CGFloat = 54
        static let cornerRadius: CGFloat = 16
        static let titleAnimationDelay: UInt64 = 100_000_000 // 0.1 seconds
        static let formAnimationDelay: UInt64 = 300_000_000 // 0.3 seconds
        static let titleAnimationDuration: Double = 0.6
        static let formAnimationDuration: Double = 0.8
        static let vStackSpacing: CGFloat = 10
        static let formSpacing: CGFloat = 20
        static let fieldSpacing: CGFloat = 8
        static let sectionSpacing: CGFloat = 16
        static let headerSpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let topPadding: CGFloat = 20
        static let pickerHeight: CGFloat = 40
        
        static let spacerMinLength: CGFloat = 30
        static let spacerMediumLength: CGFloat = 20
        static let spacerSmallLength: CGFloat = 10
        
        static let styles = ["Adventure", "Fantasy", "Educational", "Mystery"]
        static let fieldBorderWidth: CGFloat = 2
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = (x: CGFloat(0), y: CGFloat(2))
        static let progressViewScale: CGFloat = 0.8
        static let disabledOpacity: Double = 0.6
        static let textAreaMinHeight: CGFloat = 100
        
        // Colors
        static let placeholderColor = Color.gray
        static let createButtonBorderColor = Color(red: 0.95, green: 0.75, blue: 0.85)
        static let borderColor = Color.white
        static let selectedBorderOpacity = 1.0
        static let unselectedBorderOpacity = 0.5
        static let backButtonBottomSpacing: CGFloat = 6
        static let orangeBorder = AppColors.orangeBorder
        
        // Reusable padding values
        static let fieldHorizontalPadding: CGFloat = 16
        static let fieldVerticalPadding: CGFloat = 12
        static let textAreaHorizontalPadding: CGFloat = 20
        static let textAreaVerticalPadding: CGFloat = 20
        static let standardSpacing: CGFloat = 8
    }
    
    var body: some View {
        creatorContent
            .navigationBarHidden(true)
            .background(backgroundView)
            .onTapGesture(perform: hideKeyboard)
            .onAppear {
                startAnimations()
                loadUserHeroes()
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
    }
    
    private var creatorContent: some View {
        VStack(spacing: 0) {
            scrollableForm
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var scrollableForm: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Constants.vStackSpacing) {
                    Spacer(minLength: Constants.spacerMinLength)
                        .id("top")
                    titleSection
                    Spacer(minLength: Constants.spacerMediumLength)
                    heroForm
                    Spacer(minLength: Constants.spacerSmallLength)
                    actionButtons
                    Spacer(minLength: 30)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
        }
    }
    
    private var titleSection: some View {
        titleTexts
    }
    
    private var titleTexts: some View {
        VStack(spacing: Constants.titleSpacing) {
            Text("Create Your Story")
                .font(.appH1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            Text(subtitleText)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            if userHeroes.isEmpty {
                backToHeroCreationButton
                    .animatedContent(opacity: titleOpacity, offset: titleOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    private var backToHeroCreationButton: some View {
        Button(action: {
            // Переходим назад к первому экрану для создания героя
            NotificationCenter.default.post(name: Notification.Name("GoToHeroCreation"), object: nil)
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.appBackIcon)
                    .foregroundColor(.white)
                
                Text("Create Character First")
                    .font(.appBackText)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 16)
    }
    
    private var heroForm: some View {
        VStack(spacing: Constants.formSpacing) {
            storyConfigSection
        }
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: formOpacity, offset: formOffset)
    }
    
    private var storyConfigSection: some View {
        VStack(spacing: Constants.formSpacing) {
            formField(
                label: "story_name_label".localized,
                placeholder: "story_name_placeholder".localized,
                text: $storyName
            )
            
            styleField
            languageField
        }
    }
    
    private func formField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text(label)
                .font(.appLabel)
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Constants.placeholderColor)
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
                    .stroke(Constants.borderColor, lineWidth: Constants.fieldBorderWidth)
            )
            .shadow(color: AppColors.softShadow, radius: Constants.shadowRadius, x: Constants.shadowOffset.x, y: Constants.shadowOffset.y)
        }
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
                            .padding(16)
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
                            .padding(16)
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
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            nextButton
            skipButton
        }
        .padding(.horizontal, Constants.contentPadding)
        .padding(.bottom, 60)
        .animatedContent(opacity: formOpacity, offset: formOffset)
    }
    
    private var nextButton: some View {
        Button(action: updateHeroAndNext) {
            HStack {
                if isCreating {
                    ProgressView()
                        .scaleEffect(Constants.progressViewScale)
                        .tint(.white)
                } else {
                    Text("get_started".localized)
                        .font(.appSubtitle)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background(AppColors.orangeGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Constants.orangeBorder, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 8, x: 0, y: 4)
        }
        .disabled(isCreating || hasRequestSent || !canCreateStory())
        .opacity(isCreating || hasRequestSent || !canCreateStory() ? Constants.disabledOpacity : 1.0)
    }
    
    private var skipButton: some View {
        Button(action: {
            hideKeyboard()
            onSkip()
        }) {
            Text("skip".localized)
                .font(.appSubtitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(Color.clear)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
    
    
    private var backgroundView: some View {
        ZStack {
            Image("bg_2")
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
    
    // MARK: - Animation Methods
    private func startAnimations() {
        animateTitle()
        animateForm()
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
    
    // MARK: - Helper Methods
    private func trimmedString(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    private func isValidStoryName() -> Bool {
        return !(storyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private func canCreateStory() -> Bool {
        return !userHeroes.isEmpty && 
               isValidStoryName()
    }
    
    private func updateHeroAndNext() {
        hideKeyboard()
        
        guard canCreateStory() else {
            if userHeroes.isEmpty {
                alertMessage = "You need to create a hero first"
            } else if storyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                alertMessage = "Story name is required"
            }
            showingAlert = true
            return
        }
        
        isCreating = true
        hasRequestSent = true
        
        // Получаем первого героя из списка  
        let selectedHeroes = userHeroes.isEmpty ? [] : [userHeroes.first!]
        
        // Создаем запрос на генерацию истории
        let storyRequest = StoryGenerateRequest(
            story_name: trimmedString(storyName) ?? "",
            story_idea: "my first magic story",
            story_style: selectedStyle,
            language: selectedLanguage.rawValue,
            story_length: 1,
            heroes: selectedHeroes
        )
        
        Task {
            let storyService = StoryService.shared
            storyService.generateStoryStream(request: storyRequest)
            
            await MainActor.run {
                isCreating = false
                
                // Проверяем, есть ли ошибка
                if storyService.errorMessage == nil {
                    // История успешно начала генерироваться, передаем данные и переходим на третий экран
                    // hasRequestSent остается true навсегда - кнопка больше не активна
                    onStoryGenerated(storyRequest)
                    onNext()
                } else {
                    // Сбрасываем флаг только при ошибке, чтобы можно было повторить попытку
                    hasRequestSent = false
                    alertMessage = storyService.errorMessage ?? "Failed to generate story"
                    showingAlert = true
                }
            }
        }
    }
    
    private func loadUserHeroes() {
        Task {
            let heroes = await heroService.fetchUserHeroes()
            await MainActor.run {
                userHeroes = heroes
            }
        }
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
    OnboardingScreen2(
        onNext: { print("Next tapped") },
        onSkip: { print("Skip tapped") },
        onStoryGenerated: { _ in print("Story generated") }
    )
}
