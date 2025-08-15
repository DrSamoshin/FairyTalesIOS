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
    @State private var storyManager = StoryManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var storyName = ""
    @State private var heroName = ""
    @State private var age = 5
    @State private var idea = ""
    @State private var selectedStyle = "Adventure"
    @State private var selectedLanguage: SupportedLanguage = .english
    @State private var showStoryView = false
    @State private var showStreamingView = false
    @State private var showingAlert = false
    @State private var progressValue: Double = 0.0
    @State private var progressTimer: Timer?
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
        static let titleSpacing: CGFloat = 8
        static let formSpacing: CGFloat = 20
        static let fieldSpacing: CGFloat = 8
        static let progressTimerInterval: Double = 0.1
        static let progressIncrement: Double = 0.02
        static let progressMaxValue: Double = 0.95
        static let progressCompletionDelay: Double = 0.5
        static let progressAnimationDuration: Double = 0.3
        
        static let styles = ["Adventure", "Fantasy", "Educational", "Mystery"]
    }
    
    private var isTimeoutError: Bool {
        return storyManager.errorMessage?.contains("story_timeout_message".localized) == true ||
               storyManager.errorMessage?.contains("timeout_error_occurred".localized) == true
    }
    
    var body: some View {
        NavigationStack {
            storyCreatorContent
        }
        .alert(isTimeoutError ? "story_timeout_title".localized : "Error", isPresented: $showingAlert) {
            alertButtons
        } message: {
            Text(storyManager.errorMessage ?? "Unknown error")
        }
        .onChange(of: storyManager.errorMessage) { _, newError in
            showingAlert = newError != nil
        }
        .navigationDestination(isPresented: $showStoryView) {
            if let story = storyManager.currentStory {
                StoryViewScreen(story: story)
            }
        }
        .navigationDestination(isPresented: $showStreamingView) {
            StoryStreamingViewScreen(
                storyName: storyName,
                heroName: heroName,
                age: age,
                storyStyle: selectedStyle,
                language: selectedLanguage.rawValue,
                storyIdea: idea
            )
        }
        .onDisappear(perform: cleanupTimer)
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
        .mask(scrollMask)
    }
    
    private var scrollMask: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black, location: 0.05),
                .init(color: .black, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    @ViewBuilder
    private var alertButtons: some View {
        if isTimeoutError {
            Button("check_stories_later".localized) {
                storyManager.errorMessage = nil
                presentationMode.wrappedValue.dismiss()
            }
            Button("OK") {
                storyManager.errorMessage = nil
            }
        } else {
            Button("OK") {
                storyManager.errorMessage = nil
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
.animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            Text("story_creator_subtitle".localized)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
.animatedContent(opacity: titleOpacity, offset: titleOffset)
        }
        .frame(maxWidth: .infinity)
.padding(.horizontal, Constants.contentPadding)
    }
    
    // MARK: - Form Components
    private var storyForm: some View {
        VStack(spacing: 20) {
            formField(label: "story_name_label".localized, placeholder: "story_name_placeholder".localized, text: $storyName)
            formField(label: "hero_name_label".localized, placeholder: "hero_name_placeholder".localized, text: $heroName)
            ageField
            styleField
            languageField
            ideaField
        }
.padding(.horizontal, Constants.contentPadding)
.animatedContent(opacity: formOpacity, offset: formOffset)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("age_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text("age_format".localized(age))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
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
    
    private var styleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("story_style_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(Constants.styles, id: \.self) { style in
                    Button(action: {
                        selectedStyle = style
                    }) {
                        Text(style.lowercased().localized)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
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
        VStack(alignment: .leading, spacing: 8) {
            Text("language_label".localized)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                    }) {
                        Text(language.shortName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
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
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Action Components
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if storyManager.isLoading {
                // Progress view during generation
                VStack(spacing: 12) {
                    ProgressView(value: progressValue, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.fairyPurple))
                        .scaleEffect(y: 2)
                    
                    HStack {
                        Text("creating_magic".localized)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(progressValue * 100))%")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Text("please_wait_generating".localized)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
        .padding(.horizontal, Constants.contentPadding)
            } else {
                // Generate button
                Button(action: generateStory) {
                    Text("generate_story".localized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
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
            }
        }
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
    
    private func generateStory() {
        print("🎭 Generating story with streaming...")
        print("📝 Story: \(storyName), Hero: \(heroName), Age: \(age)")
        print("🎨 Style: \(selectedStyle), Language: \(selectedLanguage.rawValue)")
        print("💡 Idea: \(idea)")
        
        // Navigate immediately to streaming view
        showStreamingView = true
    }
    
    // MARK: - Progress Timer Methods
    private func startProgressTimer() {
        progressValue = 0.0
        progressTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressTimerInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.progressValue < Constants.progressMaxValue {
                    let increment = (1.0 - self.progressValue) * Constants.progressIncrement
                    self.progressValue += increment
                }
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        
        withAnimation(.easeInOut(duration: Constants.progressAnimationDuration)) {
            progressValue = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.progressCompletionDelay) {
            self.progressValue = 0.0
        }
    }
    
    private func cleanupTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - Utility Methods
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
