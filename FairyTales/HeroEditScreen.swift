//
//  HeroEditScreen.swift
//  FairyTales
//
//  Created by Assistant on 29/08/2025.
//

import SwiftUI

struct HeroEditScreen: View {
    // MARK: - Properties
    let hero: Hero
    
    // MARK: - State
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var heroService = HeroService.shared
    @State private var heroName: String
    @State private var heroAppearance: String
    @State private var heroPersonality: String
    @State private var heroPower: String
    @State private var age: Int
    @State private var selectedGender: HeroGender
    @State private var isUpdating = false
    @State private var isDeleting = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteConfirmation = false
    
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
        
        // Delete button colors
        static let deleteButtonBorderColor = Color(red: 1.0, green: 0.7, blue: 0.7) // Light red
        
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
        static let backButtonBottomSpacing: CGFloat = 6
        
        // Reusable padding values
        static let fieldHorizontalPadding: CGFloat = 16
        static let fieldVerticalPadding: CGFloat = 12
        static let textAreaHorizontalPadding: CGFloat = 20
        static let textAreaVerticalPadding: CGFloat = 20
        static let standardSpacing: CGFloat = 8
        static let mediumSpacing: CGFloat = 16
        
        // Colors
        static let placeholderColor = Color.gray
        static let borderColor = Color.white
        static let selectedBorderOpacity = 1.0
        static let unselectedBorderOpacity = 0.5
        static let saveButtonBorderColor = Color(red: 0.95, green: 0.75, blue: 0.85)
    }
    
    // MARK: - Initializer
    init(hero: Hero) {
        self.hero = hero
        self._heroName = State(initialValue: hero.name)
        self._heroAppearance = State(initialValue: hero.appearance ?? "")
        self._heroPersonality = State(initialValue: hero.personality ?? "")
        self._heroPower = State(initialValue: hero.power ?? "")
        self._age = State(initialValue: hero.age)
        self._selectedGender = State(initialValue: HeroGender(rawValue: hero.gender) ?? .male)
    }
    
    var body: some View {
        editorContent
            .navigationBarHidden(true)
            .background(backgroundView)
            .onTapGesture(perform: hideKeyboard)
            .onAppear(perform: startAnimations)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("confirm_delete_hero".localized, isPresented: $showingDeleteConfirmation) {
                Button("delete_hero".localized, role: .destructive) {
                    deleteHero()
                }
                Button("cancel".localized, role: .cancel) { }
            }
    }
    
    private var editorContent: some View {
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, Constants.contentPadding)
                .padding(.top, Constants.topPadding)
                .padding(.bottom, Constants.backButtonBottomSpacing)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            scrollableForm
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var scrollableForm: some View {
        ScrollView {
            VStack(spacing: Constants.vStackSpacing) {
                Spacer(minLength: Constants.spacerMinLength)
                titleSection
                Spacer(minLength: Constants.spacerMediumLength)
                heroForm
                Spacer(minLength: Constants.spacerSmallLength)
                actionButtons
                Spacer(minLength: Constants.spacerMinLength)
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
        VStack(spacing: Constants.standardSpacing) {
            Text("edit_hero".localized)
                .font(.appH1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .animatedContent(opacity: titleOpacity, offset: titleOffset)
            
            Text("edit_hero_subtitle".localized)
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
            
            ideaField(
                label: "appearance".localized,
                placeholder: "appearance_placeholder".localized,
                text: $heroAppearance
            )
            
            ideaField(
                label: "personality".localized,
                placeholder: "personality_placeholder".localized,
                text: $heroPersonality
            )
            
            ideaField(
                label: "power".localized,
                placeholder: "power_placeholder".localized,
                text: $heroPower
            )
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
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
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
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private func ideaField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Constants.fieldSpacing) {
            Text(label)
                .font(.appLabel)
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Constants.placeholderColor)
                        .font(.appInputField)
                        .padding(.horizontal, Constants.textAreaHorizontalPadding)
                        .padding(.vertical, Constants.textAreaVerticalPadding)
                }
                TextEditor(text: text)
                    .foregroundColor(AppColors.darkText)
                    .font(.appInputField)
                    .frame(minHeight: Constants.textAreaMinHeight)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, Constants.fieldHorizontalPadding)
                    .padding(.vertical, Constants.fieldVerticalPadding)
            }
            .background(AppColors.fieldGradient)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Constants.borderColor, lineWidth: Constants.fieldBorderWidth)
            )
            .shadow(color: AppColors.softShadow, radius: 4, x: 0, y: 2)
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
                .stroke(strokeColorForGenderButton(isSelected: isSelected), lineWidth: Constants.fieldBorderWidth)
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
        VStack(spacing: Constants.mediumSpacing) {
            // Save Button
            Button(action: updateHero) {
                HStack {
                    if isUpdating {
                        ProgressView()
                            .scaleEffect(Constants.progressViewScale)
                            .tint(.white)
                    } else {
                        Text("save_hero".localized)
                            .font(.appSubtitle)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(AppColors.contrastPrimary)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Constants.saveButtonBorderColor, lineWidth: Constants.fieldBorderWidth)
                )
            }
            .disabled(isUpdating || isDeleting || !isValidHeroName())
            .opacity(isUpdating || isDeleting || !isValidHeroName() ? Constants.disabledOpacity : 1.0)
            
            // Delete Button
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .scaleEffect(Constants.progressViewScale)
                            .tint(.white)
                    } else {
                        Text("delete_hero".localized)
                            .font(.appSubtitle)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(Color.red.opacity(0.8))
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Constants.deleteButtonBorderColor, lineWidth: Constants.fieldBorderWidth)
                )
            }
            .disabled(isUpdating || isDeleting)
            .opacity(isUpdating || isDeleting ? Constants.disabledOpacity : 1.0)
        }
        .padding(.horizontal, Constants.contentPadding)
        .animatedContent(opacity: formOpacity, offset: formOffset)
    }
    
    private var backgroundView: some View {
        ZStack {
            Image("bg_7")
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
    
    private func updateHero() {
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
        
        isUpdating = true
        
        let updateRequest = HeroUpdateRequest(
            name: trimmedString(heroName) ?? "",
            gender: selectedGender.rawValue,
            age: age,
            appearance: trimmedString(heroAppearance),
            personality: trimmedString(heroPersonality),
            power: trimmedString(heroPower),
            avatar_image: nil
        )
        
        Task {
            let updatedHero = await heroService.updateHero(heroId: hero.id ?? "", request: updateRequest)
            await MainActor.run {
                isUpdating = false
                
                if updatedHero != nil {
                    // Hero updated successfully, go back
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // Show error
                    alertMessage = heroService.errorMessage ?? "Failed to update hero"
                    showingAlert = true
                }
            }
        }
    }
    
    private func deleteHero() {
        guard let heroId = hero.id else {
            alertMessage = "Cannot delete hero: Invalid hero ID"
            showingAlert = true
            return
        }
        
        isDeleting = true
        
        Task {
            let success = await heroService.deleteHero(heroId: heroId)
            await MainActor.run {
                isDeleting = false
                
                if success {
                    // Hero deleted successfully, go back
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // Show error
                    alertMessage = heroService.errorMessage ?? "failed_to_delete_hero".localized
                    showingAlert = true
                }
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
        HeroEditScreen(hero: Hero(
            id: "1",
            user_id: "user1",
            name: "Test Hero",
            gender: "boy",
            age: 8,
            appearance: "Tall and brave",
            personality: "Kind and helpful",
            power: "Fire magic",
            avatar_image: nil,
            created_at: nil,
            updated_at: nil
        ))
    }
}
