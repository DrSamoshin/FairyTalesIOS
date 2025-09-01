//
//  HeroCreatorScreen.swift
//  FairyTales
//
//  Created by Assistant on 27/08/2025.
//

import SwiftUI

struct OnboardingScreen1: View {
    // MARK: - Properties
    let onNext: () -> Void
    let onSkip: () -> Void
    
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var heroService = HeroService.shared
    @State private var heroName: String = ""
    @State private var heroAppearance: String = ""
    @State private var heroPersonality: String = ""
    @State private var heroPower: String = ""
    @State private var age = 5
    @State private var selectedGender: HeroGender = .male
    @State private var userHeroes: [Hero] = []
    @State private var isCreating = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Animation states
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30.0
    @State private var formOpacity: Double = 0.0
    @State private var formOffset: CGFloat = 20.0
    
    @Environment(\.presentationMode) var presentationMode
    
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
        
        // Using shared button styles
        typealias ButtonConfig = ButtonStyles.ButtonConfig
        
        // UI Constants
        static let minAge = 3
        static let maxAge = 12
        static let ageStep = 1
        static let fadeHeight: CGFloat = 25
        static let spacerMinLength: CGFloat = 30
        static let spacerMediumLength: CGFloat = 20
        static let spacerSmallLength: CGFloat = 10
        static let genderButtonSpacing: CGFloat = 12
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
    
    private var backButton: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: Constants.standardSpacing) {
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
        titleTexts
    }
    
    private var titleTexts: some View {
        VStack(spacing: Constants.titleSpacing) {
            Text("Create First Character")
                .font(.appH1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            Text("Let's create your first story hero to get started with magical adventures")
                .font(.appSubtitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.contentPadding)
    }
    
    private var heroForm: some View {
        VStack(spacing: Constants.formSpacing) {
            basicInfoSection
        }
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: formOpacity, offset: formOffset)
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: Constants.formSpacing) {
            formField(
                label: "hero_name_label".localized,
                placeholder: "hero_name_placeholder".localized,
                text: $heroName
            )
            
            ageField
            genderField
            
        }
    }
    
    
    private var ageField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("age_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            VStack(spacing: Constants.standardSpacing) {
                HStack {
                    Text(String(format: "age_format".localized, age))
                        .font(.appLabel)
                        .foregroundColor(AppColors.darkText)
                    Spacer()
                }
                
                Slider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0.rounded()) }
                ), in: Double(Constants.minAge)...Double(Constants.maxAge), step: Double(Constants.ageStep))
                .tint(AppColors.contrastPrimary.opacity(0.8))
            }
            .padding(.horizontal, Constants.fieldHorizontalPadding)
            .padding(.vertical, Constants.fieldVerticalPadding)
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Constants.borderColor, lineWidth: Constants.fieldBorderWidth)
            )
            .shadow(color: AppColors.softShadow, radius: Constants.shadowRadius, x: Constants.shadowOffset.x, y: Constants.shadowOffset.y)
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
    
   
    private var genderField: some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text("child_gender_label".localized)
                .font(.appLabel)
                .foregroundColor(.white)
            
            HStack(spacing: Constants.genderButtonSpacing) {
                ForEach(HeroGender.allCases, id: \.self) { gender in
                    genderButton(for: gender)
                }
            }
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private func genderButton(for gender: HeroGender) -> some View {
        Button(action: {
            selectedGender = gender
        }) {
            genderButtonContent(for: gender)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func genderButtonContent(for gender: HeroGender) -> some View {
        let isSelected = selectedGender == gender
        
        return HStack(spacing: Constants.standardSpacing) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .white : .gray)
                .font(.appBody)
            
            Text(gender.localizedName)
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
    private func backgroundForGenderButton(isSelected: Bool, gender: HeroGender) -> some View {
        if isSelected {
            if gender == .male {
                AppColors.contrastSecondary
            } else {
                AppColors.contrastPrimary
            }
        } else {
            AppColors.fieldGradient
        }
    }
    
    private func strokeColorForGenderButton(isSelected: Bool) -> Color {
        return isSelected ?
            Constants.borderColor.opacity(Constants.selectedBorderOpacity) :
            Constants.borderColor.opacity(Constants.unselectedBorderOpacity)
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
        Button(action: createHeroAndNext) {
            HStack {
                if isCreating {
                    ProgressView()
                        .scaleEffect(Constants.progressViewScale)
                        .tint(.white)
                } else {
                    Text("next".localized)
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
        .disabled(isCreating || !isValidHeroName())
        .opacity(isCreating || !isValidHeroName() ? Constants.disabledOpacity : 1.0)
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
            Image("bg_8")
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
    
    private func isValidHeroName() -> Bool {
        return !(heroName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private func createHeroAndNext() {
        hideKeyboard()
        
        // Если герой уже есть, просто переходим на следующий экран
        if !userHeroes.isEmpty {
            onNext()
            return
        }
        
        guard isValidHeroName() else {
            alertMessage = "hero_name_required".localized
            showingAlert = true
            return
        }
        
        guard age >= Constants.minAge && age <= Constants.maxAge else {
            alertMessage = "Invalid age range"
            showingAlert = true
            return
        }
        
        isCreating = true
        
        let heroRequest = HeroCreateRequest(
            name: trimmedString(heroName) ?? "",
            gender: selectedGender.rawValue,
            age: age,
            appearance: nil,
            personality: nil,
            power: nil,
            avatar_image: nil
        )
        
        Task {
            let createdHero = await heroService.createHero(request: heroRequest)
            await MainActor.run {
                isCreating = false
                
                if createdHero != nil {
                    // Hero created successfully, proceed to next onboarding screen
                    onNext()
                } else {
                    // Show error
                    alertMessage = heroService.errorMessage ?? "Failed to create hero"
                    showingAlert = true
                }
            }
        }
    }
    
    private func createHero() {
        guard isValidHeroName() else {
            alertMessage = "hero_name_required".localized
            showingAlert = true
            return
        }
        
        guard age >= Constants.minAge && age <= Constants.maxAge else {
            alertMessage = "Invalid age range"
            showingAlert = true
            return
        }
        
        isCreating = true
        
        let heroRequest = HeroCreateRequest(
            name: trimmedString(heroName) ?? "",
            gender: selectedGender.rawValue,
            age: age,
            appearance: trimmedString(heroAppearance),
            personality: trimmedString(heroPersonality),
            power: trimmedString(heroPower),
            avatar_image: nil
        )
        
        
        Task {
            let createdHero = await heroService.createHero(request: heroRequest)
            await MainActor.run {
                isCreating = false
                
                if createdHero != nil {
                    // Hero created successfully, go back
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // Show error
                    alertMessage = heroService.errorMessage ?? "Failed to create hero"
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
    NavigationView {
        HeroCreatorScreen()
    }
}
