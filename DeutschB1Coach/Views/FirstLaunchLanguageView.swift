import SwiftUI

enum FirstLaunchFlow {
    static let didChooseLanguageStorageKey = "didChooseTeachingLanguage.v1"
    static let didCompleteTutorialStorageKey = "didCompleteFirstLaunchTutorial.v1"

    static func requiresLanguageSelection(
        didChooseLanguage: Bool,
        didCompleteOnboarding: Bool
    ) -> Bool {
        !didChooseLanguage && !didCompleteOnboarding
    }

    static func requiresTutorial(
        didChooseLanguage: Bool,
        didCompleteTutorial: Bool,
        didCompleteOnboarding: Bool
    ) -> Bool {
        didChooseLanguage && !didCompleteTutorial && !didCompleteOnboarding
    }
}

struct FirstLaunchLanguageView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var languageCode: String
    @Binding var didChooseLanguage: Bool
    @State private var selectedCode = ""
    @State private var searchText = ""

    private var selectedLanguage: TeachingLanguage? {
        TeachingLanguage(rawValue: selectedCode)
    }

    private var filteredLanguages: [TeachingLanguage] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return TeachingLanguage.allCases
        }
        return TeachingLanguage.allCases.filter {
            $0.nativeName.localizedCaseInsensitiveContains(searchText)
                || $0.englishName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    header
                    searchField

                    ForEach(Array(filteredLanguages.enumerated()), id: \.element.id) { index, language in
                        languageRow(language, index: index)
                    }

                    Label(
                        "Your language choice and learning progress stay on this iPhone.",
                        systemImage: "lock.shield.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 112)
            }
            .navigationTitle("Language · Sprache")
            .navigationBarTitleDisplayMode(.inline)
            .coachBackground()
            .safeAreaInset(edge: .bottom) {
                continueBar
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            CoachIconTile(icon: "globe", tint: CoachTheme.listening, size: 62)
            VStack(alignment: .leading, spacing: 5) {
                Text("Choose your language")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                Text("አማርኛ · ትግርኛ · اختر لغتك · Dilini seç · Elige tu idioma")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("German stays German. Explanations and navigation use the language you select.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(CoachTheme.listening)
                .accessibilityHidden(true)
            TextField("Search language", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .teachingAccessibilityLabel("Clear language search")
            }
        }
        .padding(.horizontal, 13)
        .frame(minHeight: 50)
        .background(
            CoachTheme.elevatedSurface,
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke(CoachTheme.listening.opacity(0.22))
        )
    }

    private func languageRow(_ language: TeachingLanguage, index: Int) -> some View {
        let isSelected = selectedCode == language.rawValue
        let tint = languageTint(index)

        return Button {
            if reduceMotion {
                selectedCode = language.rawValue
            } else {
                withAnimation(CoachMotion.spring) {
                    selectedCode = language.rawValue
                }
            }
            CoachFeedback.selection()
        } label: {
            HStack(spacing: 13) {
                Text(language.flag)
                    .font(.system(size: 29))
                    .frame(width: 46, height: 46)
                    .background(tint.opacity(0.12), in: Circle())
                    .overlay(Circle().stroke(tint.opacity(0.25)))
                    .accessibilityHidden(true)
                VStack(alignment: language.isRightToLeft ? .trailing : .leading, spacing: 2) {
                    Text(language.nativeName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    if language.nativeName != language.englishName {
                        Text(language.englishName)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: language.isRightToLeft ? .trailing : .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isSelected ? tint : Color.secondary.opacity(0.45))
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
            .background(
                LinearGradient(
                    colors: isSelected
                        ? [tint.opacity(0.18), CoachTheme.elevatedSurface, CoachTheme.rewardGlow.opacity(0.10)]
                        : [CoachTheme.elevatedSurface, tint.opacity(0.07)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                    .stroke(tint.opacity(isSelected ? 0.65 : 0.18), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(language.pickerName)
        .teachingAccessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var continueBar: some View {
        VStack(spacing: 8) {
            Button {
                guard let selectedLanguage else { return }
                languageCode = selectedLanguage.rawValue
                didChooseLanguage = true
                CoachFeedback.success()
            } label: {
                HStack(spacing: 8) {
                    Text(selectedLanguage?.interfaceText(.continueAction) ?? "Choose a language")
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryCoachButton(tint: selectedLanguage.map { _ in CoachTheme.primary } ?? Color.secondary))
            .disabled(selectedLanguage == nil)

            if let selectedLanguage {
                HStack(spacing: 6) {
                    Text(selectedLanguage.flag)
                        .accessibilityHidden(true)
                    Text(selectedLanguage.pickerName)
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(selectedLanguage.pickerName)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private func languageTint(_ index: Int) -> Color {
        let palette = [
            CoachTheme.primary,
            CoachTheme.accent,
            CoachTheme.listening,
            CoachTheme.reward,
            CoachTheme.speaking,
            CoachTheme.reading
        ]
        return palette[index % palette.count]
    }
}
