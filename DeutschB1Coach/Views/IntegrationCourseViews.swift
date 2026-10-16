import SwiftUI
import UIKit

enum OrientationQuestionProgress {
    static let storageKey = "masteredOrientationQuestions.v1"

    static func masteredIDs(from rawValue: String) -> Set<String> {
        guard let data = rawValue.data(using: .utf8),
              let values = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(values)
    }

    static func encoded(_ masteredIDs: Set<String>) -> String {
        let values = masteredIDs.sorted()
        guard let data = try? JSONEncoder().encode(values) else { return "[]" }
        return String(decoding: data, as: UTF8.self)
    }
}

private enum OrientationHubMode: String, CaseIterable, Hashable {
    case number = "Nach Nummer"
    case exam = "Prüfung"
    case catalog = "Katalog"

    var icon: String {
        switch self {
        case .number: "number.square.fill"
        case .exam: "checkmark.seal.fill"
        case .catalog: "list.bullet.clipboard.fill"
        }
    }

    var tint: Color {
        switch self {
        case .number: CoachTheme.primary
        case .exam: CoachTheme.listening
        case .catalog: CoachTheme.reward
        }
    }
}

struct OrientationQuestionCatalogOverview: View {
    @AppStorage(OrientationQuestionProgress.storageKey) private var masteredRaw = "[]"
    @AppStorage(GermanFederalState.storageKey) private var selectedStateCode = ""
    @State private var selectedMode = OrientationHubMode.number

    private let previewState: GermanFederalState?

    init(previewState: GermanFederalState? = nil) {
        self.previewState = previewState
    }

    private var selectedState: GermanFederalState? {
        previewState ?? GermanFederalState(rawValue: selectedStateCode)
    }

    private var catalogs: [OrientationQuestionCatalog] {
        guard let selectedState else { return [] }
        return IntegrationCourseCurriculum.orientationQuestionCatalogs(for: selectedState)
    }

    private var questions: [OrientationQuestion] {
        catalogs.flatMap(\.questions)
    }

    private var masteredIDs: Set<String> {
        OrientationQuestionProgress.masteredIDs(from: masteredRaw)
            .intersection(questions.map(\.id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let error = OrientationQuestionRepository.loadErrorDescription {
                CoachCard(tint: CoachTheme.incorrect) {
                    CoachEmptyState(
                        icon: "exclamationmark.triangle.fill",
                        title: "Fragenkatalog nicht verfügbar",
                        message: error,
                        tint: CoachTheme.incorrect
                    )
                }
            } else if let selectedState {
                overview(for: selectedState)
            } else {
                stateSelection
            }
        }
        .teachingNavigationTitle("Orientation")
    }

    private func overview(for state: GermanFederalState) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            CoachCard(tint: CoachTheme.reward) {
                VStack(alignment: .leading, spacing: 13) {
                    HStack(alignment: .top, spacing: 12) {
                        CoachIconTile(icon: "list.bullet.clipboard.fill", tint: CoachTheme.reward, size: 52)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fragenkatalog Orientierungskurs")
                                .font(.title2.weight(.bold))
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Leben in Deutschland")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 7) {
                            SkillChip(title: "300 allgemein", color: CoachTheme.listening, translatesTitle: false)
                            SkillChip(title: "10 × \(state.name)", color: CoachTheme.reward, translatesTitle: false)
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            SkillChip(title: "300 allgemeine Fragen", color: CoachTheme.listening, translatesTitle: false)
                            SkillChip(title: "10 Fragen für \(state.name)", color: CoachTheme.reward, translatesTitle: false)
                        }
                    }

                    Menu {
                        ForEach(GermanFederalState.allCases) { federalState in
                            Button {
                                selectedStateCode = federalState.rawValue
                                CoachFeedback.selection()
                            } label: {
                                if federalState == state {
                                    Label(federalState.name, systemImage: "checkmark")
                                } else {
                                    Text(federalState.name)
                                }
                            }
                        }
                    } label: {
                        Label(state.name, systemImage: "map.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
                    .accessibilityLabel("Bundesland: \(state.name). Ändern")

                    LessonProgressBar(
                        progress: questions.isEmpty ? 0 : Double(masteredIDs.count) / Double(questions.count)
                    )
                    Text("\(masteredIDs.count) von \(questions.count) Fragen sicher beantwortet")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            CoachCategoryPicker(
                title: "Übungsart",
                selection: $selectedMode,
                options: OrientationHubMode.allCases.map {
                    CoachCategoryOption(
                        value: $0,
                        title: $0.rawValue,
                        icon: $0.icon,
                        tint: $0.tint
                    )
                }
            )

            orientationModeContent(for: state)
        }
    }

    @ViewBuilder private func orientationModeContent(for state: GermanFederalState) -> some View {
        switch selectedMode {
        case .number:
            NavigationLink {
                OrientationQuestionNumberPracticeView(state: state)
            } label: {
                CoachCard(tint: CoachTheme.primary) {
                    HStack(spacing: 13) {
                        CoachIconTile(icon: "number.square.fill", tint: CoachTheme.primary, size: 50)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Frage nach Nummer öffnen")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Wähle eine allgemeine Frage von 1 bis 300 oder eine Landesfrage von 1 bis 10.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.primary)
                            .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())

        case .exam:
            VStack(alignment: .leading, spacing: 11) {
                CoachSectionHeader(
                    title: "Prüfung üben",
                    subtitle: "Jeder Versuch erstellt einen neuen Testbogen"
                )
                NavigationLink {
                    OrientationMockExamView(state: state)
                } label: {
                    OrientationMockExamEntryCard(state: state)
                }
                .buttonStyle(CoachCardButtonStyle())
            }

        case .catalog:
            VStack(alignment: .leading, spacing: 11) {
                CoachSectionHeader(
                    title: "Deine 310 Fragen",
                    subtitle: "Drei allgemeine Kataloge und dein Bundesland"
                )
                VStack(spacing: 10) {
                    ForEach(Array(catalogs.enumerated()), id: \.element.id) { index, catalog in
                        NavigationLink {
                            OrientationQuestionCatalogView(catalog: catalog, tint: orientationTint(index))
                        } label: {
                            OrientationQuestionCatalogRow(
                                catalog: catalog,
                                tint: orientationTint(index),
                                mastered: masteredCount(in: catalog)
                            )
                        }
                        .buttonStyle(CoachCardButtonStyle())
                    }
                }
                sourceNote
            }
        }
    }

    private var stateSelection: some View {
        CoachCard(tint: CoachTheme.primary) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    CoachIconTile(icon: "map.fill", tint: CoachTheme.primary, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wähle dein Bundesland")
                            .font(.title2.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Dann erhältst du 300 allgemeine und genau 10 passende Landesfragen.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Picker("Bundesland", selection: $selectedStateCode) {
                    Text("Bitte auswählen").tag("")
                    ForEach(GermanFederalState.allCases) { state in
                        Text(state.name).tag(state.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .padding(.horizontal, 12)
                .background(
                    CoachTheme.elevatedSurface,
                    in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                        .stroke(CoachTheme.primary.opacity(0.20))
                )

                Label("Die Auswahl wird nur auf diesem iPhone gespeichert.", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var sourceNote: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label {
                Text("Amtlicher BAMF-Gesamtfragenkatalog, Stand \(OrientationQuestionRepository.source.date)")
            } icon: {
                Image(systemName: "checkmark.shield.fill")
            }
            if let url = URL(string: OrientationQuestionRepository.source.url) {
                Link(destination: url) {
                    Label("Quelle beim BAMF öffnen", systemImage: "arrow.up.right.square")
                }
                .accessibilityLabel("Amtliche Quelle beim BAMF öffnen")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func masteredCount(in catalog: OrientationQuestionCatalog) -> Int {
        masteredIDs.intersection(catalog.questions.map(\.id)).count
    }
}

private enum OrientationQuestionFilter: String, CaseIterable, Identifiable {
    case all = "Alle"
    case open = "Offen"
    case mastered = "Sicher"

    var id: String { rawValue }
}

private struct OrientationQuestionCatalogView: View {
    @AppStorage(OrientationQuestionProgress.storageKey) private var masteredRaw = "[]"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let catalog: OrientationQuestionCatalog
    let tint: Color

    @State private var filter = OrientationQuestionFilter.all
    @State private var visibleQuestionIDs: [String] = []
    @State private var currentIndex = 0
    @State private var selectedAnswers: [String: Int] = [:]

    private var masteredIDs: Set<String> {
        OrientationQuestionProgress.masteredIDs(from: masteredRaw)
    }

    private var visibleQuestions: [OrientationQuestion] {
        let byID = Dictionary(uniqueKeysWithValues: catalog.questions.map { ($0.id, $0) })
        return visibleQuestionIDs.compactMap { byID[$0] }
    }

    private var currentQuestion: OrientationQuestion? {
        guard visibleQuestions.indices.contains(currentIndex) else { return nil }
        return visibleQuestions[currentIndex]
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    catalogHeader

                    Picker("Fragen filtern", selection: $filter) {
                        ForEach(OrientationQuestionFilter.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    Color.clear
                        .frame(height: 0)
                        .id("orientation-question-start")

                    if let currentQuestion {
                        questionCard(currentQuestion)
                            .id(currentQuestion.id)
                            .transition(.opacity.combined(with: .scale(scale: 0.985)))
                        questionNavigation
                    } else {
                        emptyState
                            .padding(.vertical, 24)
                    }
                }
                .padding()
            }
            .onChange(of: currentIndex) { _, _ in
                if reduceMotion {
                    proxy.scrollTo("orientation-question-start", anchor: .top)
                } else {
                    withAnimation(CoachMotion.navigation) {
                        proxy.scrollTo("orientation-question-start", anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(catalog.title)
        .teachingLanguageSwitcher()
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .onAppear(perform: applyFilter)
        .onChange(of: filter) { _, _ in applyFilter() }
        .simultaneousGesture(
            DragGesture(minimumDistance: 42)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < -42 {
                        moveQuestion(by: 1)
                    } else if value.translation.width > 42 {
                        moveQuestion(by: -1)
                    }
                }
        )
    }

    private var catalogHeader: some View {
        CoachCard(tint: tint) {
            HStack(alignment: .top, spacing: 13) {
                CoachIconTile(icon: catalog.icon, tint: tint, size: 50)
                VStack(alignment: .leading, spacing: 6) {
                    Text("BAMF-FRAGENKATALOG")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(tint)
                    Text(catalog.title)
                        .font(.title3.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(catalog.subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(masteredCount)/\(catalog.questions.count) sicher beantwortet")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(tint)
                    LessonProgressBar(
                        progress: catalog.questions.isEmpty
                            ? 0
                            : Double(masteredCount) / Double(catalog.questions.count)
                    )
                }
            }
        }
    }

    private var masteredCount: Int {
        masteredIDs.intersection(catalog.questions.map(\.id)).count
    }

    private var emptyState: some View {
        CoachEmptyState(
            icon: filter == .open ? "checkmark.seal.fill" : "tray.fill",
            title: filter == .open ? "Alle Fragen sind sicher" : "Noch keine sicheren Fragen",
            message: filter == .open
                ? "Dein Fortschritt in diesem Katalog ist vollständig."
                : "Richtig beantwortete Fragen erscheinen hier.",
            tint: filter == .open ? CoachTheme.correct : tint
        )
    }

    private func questionCard(_ question: OrientationQuestion) -> some View {
        let selectedAnswer = selectedAnswers[question.id]
        let isMastered = masteredIDs.contains(question.id)

        return OrientationPracticeQuestionCard(
            question: question,
            tint: tint,
            selectedAnswer: selectedAnswer,
            isMastered: isMastered
        ) { index in
            select(index, for: question)
        }
    }

    private var questionNavigation: some View {
        VStack(spacing: 9) {
            Text("Frage \(currentIndex + 1) von \(visibleQuestions.count)")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    moveQuestion(by: -1)
                } label: {
                    Label("Zurück", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryCoachButton(tint: tint))
                .disabled(currentIndex == 0)

                Button {
                    moveQuestion(by: 1)
                } label: {
                    HStack(spacing: 7) {
                        Text("Weiter")
                        Image(systemName: "chevron.right")
                    }
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCoachButton(tint: tint))
                .disabled(currentIndex >= visibleQuestions.count - 1)
            }
        }
    }

    private func select(_ index: Int, for question: OrientationQuestion) {
        withAnimation(reduceMotion ? nil : CoachMotion.quick) {
            selectedAnswers[question.id] = index
        }

        if index == question.answerIndex {
            var mastered = masteredIDs
            mastered.insert(question.id)
            masteredRaw = OrientationQuestionProgress.encoded(mastered)
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }

    private func applyFilter() {
        let filtered: [OrientationQuestion]
        switch filter {
        case .all:
            filtered = catalog.questions
        case .open:
            filtered = catalog.questions.filter { !masteredIDs.contains($0.id) }
        case .mastered:
            filtered = catalog.questions.filter { masteredIDs.contains($0.id) }
        }
        visibleQuestionIDs = filtered.map(\.id)
        currentIndex = 0
    }

    private func moveQuestion(by offset: Int) {
        let destination = currentIndex + offset
        guard visibleQuestions.indices.contains(destination) else { return }
        if reduceMotion {
            currentIndex = destination
        } else {
            withAnimation(CoachMotion.navigation) {
                currentIndex = destination
            }
        }
        CoachFeedback.selection()
    }
}

private enum OrientationNumberScope: Hashable {
    case general
    case state

    var questionScope: OrientationQuestionScope {
        switch self {
        case .general: .general
        case .state: .state
        }
    }
}

struct OrientationQuestionNumberPracticeView: View {
    @AppStorage(OrientationQuestionProgress.storageKey) private var masteredRaw = "[]"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let state: GermanFederalState

    @State private var scope = OrientationNumberScope.general
    @State private var questionNumber = 1
    @State private var currentQuestion: OrientationQuestion?
    @State private var selectedAnswer: Int?

    private var maximumQuestionNumber: Int {
        scope == .general ? 300 : 10
    }

    private var masteredIDs: Set<String> {
        OrientationQuestionProgress.masteredIDs(from: masteredRaw)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    numberSelector

                    Color.clear
                        .frame(height: 0)
                        .id("orientation-direct-question")

                    if let currentQuestion {
                        OrientationPracticeQuestionCard(
                            question: currentQuestion,
                            tint: scope == .general ? CoachTheme.listening : CoachTheme.reward,
                            selectedAnswer: selectedAnswer,
                            isMastered: masteredIDs.contains(currentQuestion.id)
                        ) { index in
                            select(index, for: currentQuestion)
                        }
                        .id(currentQuestion.id)
                        .transition(.opacity.combined(with: .scale(scale: 0.985)))

                        directNavigation
                    }
                }
                .padding()
            }
            .onChange(of: currentQuestion?.id) { _, newValue in
                guard newValue != nil else { return }
                if reduceMotion {
                    proxy.scrollTo("orientation-direct-question", anchor: .top)
                } else {
                    withAnimation(CoachMotion.navigation) {
                        proxy.scrollTo("orientation-direct-question", anchor: .top)
                    }
                }
            }
        }
        .navigationTitle("Frage auswählen")
        .navigationBarTitleDisplayMode(.inline)
        .teachingLanguageSwitcher()
        .coachBackground()
        .onAppear {
            if currentQuestion == nil {
                openQuestion(givesFeedback: false)
            }
        }
        .onChange(of: scope) { _, _ in
            questionNumber = 1
            openQuestion()
        }
    }

    private var numberSelector: some View {
        CoachCard(tint: scope == .general ? CoachTheme.listening : CoachTheme.reward) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    CoachIconTile(icon: "number.square.fill", tint: CoachTheme.primary, size: 50)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Frage nach Nummer")
                            .font(.title2.weight(.bold))
                        Text("Wähle den Bereich und gib die gewünschte Fragenummer ein.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                CoachCategoryPicker(
                    title: "Bereich",
                    selection: $scope,
                    options: [
                        CoachCategoryOption(
                            value: .general,
                            title: "Allgemein 1–300",
                            icon: "building.columns.fill",
                            tint: CoachTheme.listening
                        ),
                        CoachCategoryOption(
                            value: .state,
                            title: "\(state.name) 1–10",
                            icon: "map.fill",
                            tint: CoachTheme.reward
                        )
                    ]
                )

                VStack(alignment: .leading, spacing: 7) {
                    Text("Fragenummer")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Picker("Fragenummer", selection: $questionNumber) {
                        ForEach(1...maximumQuestionNumber, id: \.self) { number in
                            Text("Frage \(number)")
                                .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                                .tag(number)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                    .clipped()
                    .background(
                        CoachTheme.elevatedSurface,
                        in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                            .stroke(
                                (scope == .general ? CoachTheme.listening : CoachTheme.reward)
                                    .opacity(0.28)
                            )
                    )
                    .accessibilityLabel("Fragenummer von 1 bis \(maximumQuestionNumber)")
                    .accessibilityValue("Frage \(questionNumber)")
                }

                Button {
                    openQuestion()
                } label: {
                    Label("Frage \(questionNumber) öffnen", systemImage: "arrow.down.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.primary))
            }
        }
    }

    private var directNavigation: some View {
        HStack(spacing: 10) {
            Button {
                stepQuestion(by: -1)
            } label: {
                Label("Zurück", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
            .disabled(questionNumber <= 1)

            Button {
                stepQuestion(by: 1)
            } label: {
                HStack(spacing: 7) {
                    Text("Weiter")
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.primary))
            .disabled(questionNumber >= maximumQuestionNumber)
        }
    }

    private func stepQuestion(by offset: Int) {
        questionNumber = min(max(questionNumber + offset, 1), maximumQuestionNumber)
        openQuestion()
    }

    private func openQuestion(givesFeedback: Bool = true) {
        questionNumber = min(max(questionNumber, 1), maximumQuestionNumber)
        currentQuestion = IntegrationCourseCurriculum.orientationQuestion(
            number: questionNumber,
            scope: scope.questionScope,
            for: state
        )
        selectedAnswer = nil
        if givesFeedback {
            CoachFeedback.selection()
        }
    }

    private func select(_ index: Int, for question: OrientationQuestion) {
        withAnimation(reduceMotion ? nil : CoachMotion.quick) {
            selectedAnswer = index
        }

        if index == question.answerIndex {
            var mastered = masteredIDs
            mastered.insert(question.id)
            masteredRaw = OrientationQuestionProgress.encoded(mastered)
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }
}

private struct OrientationPracticeQuestionCard: View {
    let question: OrientationQuestion
    let tint: Color
    let selectedAnswer: Int?
    let isMastered: Bool
    let onSelect: (Int) -> Void

    private var scopeTitle: String {
        question.scope == .general ? "Allgemeine Frage" : "Landesfrage"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(question.number)")
                    .font(.caption.weight(.heavy).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(tint, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(scopeTitle.uppercased())
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(tint)
                    Text(question.question)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                if isMastered {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(CoachTheme.correct)
                        .accessibilityLabel("Sicher beantwortet")
                }
            }

            if let imageName = question.imageName {
                OrientationQuestionImage(
                    name: imageName,
                    accessibilityLabel: "Abbildung zu: \(question.question)"
                )

                if question.usesNumberedImages {
                    Text("Bild 1 bis Bild 4 sind von links nach rechts angeordnet.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(Array(question.choices.enumerated()), id: \.offset) { index, choice in
                Button {
                    onSelect(index)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: selectedAnswer == index ? "largecircle.fill.circle" : "circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(choiceTint(index))
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                        Text(choice)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 4)
                        if selectedAnswer != nil && index == question.answerIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(CoachTheme.correct)
                        } else if selectedAnswer == index {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(CoachTheme.incorrect)
                        }
                    }
                }
                .buttonStyle(SecondaryCoachButton(tint: choiceTint(index)))
                .accessibilityLabel("Antwort \(index + 1) von 4: \(choice)")
                .accessibilityValue(selectedAnswer == index ? "Ausgewählt" : "Nicht ausgewählt")
            }

            if let selectedAnswer {
                CoachFeedbackPanel(
                    isCorrect: selectedAnswer == question.answerIndex,
                    title: selectedAnswer == question.answerIndex ? "Richtig" : "Noch nicht richtig",
                    message: "Richtige Antwort: \(question.answer)"
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            CoachTheme.elevatedSurface,
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke((isMastered ? CoachTheme.correct : tint).opacity(0.20))
        )
    }

    private func choiceTint(_ index: Int) -> Color {
        guard selectedAnswer != nil else { return tint }
        if index == question.answerIndex { return CoachTheme.correct }
        if selectedAnswer == index { return CoachTheme.incorrect }
        return tint
    }
}

struct OrientationQuestionImage: View {
    let name: String
    let accessibilityLabel: String

    private var bundledImage: UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    var body: some View {
        Group {
            if let bundledImage {
                Image(uiImage: bundledImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 360)
                    .accessibilityLabel(accessibilityLabel)
            } else {
                Label("Abbildung nicht verfügbar", systemImage: "photo.badge.exclamationmark")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 96)
            }
        }
        .padding(8)
        .background(Color.white, in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                .stroke(Color.black.opacity(0.08))
        )
    }
}

private struct OrientationQuestionCatalogRow: View {
    let catalog: OrientationQuestionCatalog
    let tint: Color
    let mastered: Int

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CoachIconTile(icon: catalog.icon, tint: tint, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(catalog.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(catalog.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(mastered)/\(catalog.questions.count) Fragen sicher")
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(tint)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .padding(.top, 4)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke(tint.opacity(0.17))
        )
    }
}

private func orientationTint(_ index: Int) -> Color {
    let palette = [CoachTheme.listening, CoachTheme.primary, CoachTheme.reward, CoachTheme.speaking]
    return palette[index % palette.count]
}

#if DEBUG
struct OrientationQuestionCatalogQAView: View {
    var body: some View {
        let catalogs = IntegrationCourseCurriculum.orientationQuestionCatalogs(for: .badenWuerttemberg)
        if let catalog = catalogs.last {
            NavigationStack {
                OrientationQuestionCatalogView(catalog: catalog, tint: CoachTheme.speaking)
            }
        } else {
            CoachEmptyState(
                icon: "exclamationmark.triangle.fill",
                title: "Fragenkatalog nicht verfügbar",
                message: "Die Fragen konnten nicht geladen werden."
            )
        }
    }
}
#endif
