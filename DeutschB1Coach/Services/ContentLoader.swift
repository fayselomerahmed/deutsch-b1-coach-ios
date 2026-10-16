import Foundation
import SwiftData
import Combine
import CryptoKit

enum ContentPreparationPhase: Int, CaseIterable {
    case checking
    case grammar
    case vocabularyA1
    case vocabularyA2
    case vocabularyB1
    case practice
    case saving
    case ready

    var title: String {
        switch self {
        case .checking: "Checking your course"
        case .grammar: "Building the grammar map"
        case .vocabularyA1: "A1 vocabulary is ready"
        case .vocabularyA2: "A2 vocabulary is ready"
        case .vocabularyB1: "B1 vocabulary is ready"
        case .practice: "Preparing practice"
        case .saving: "Securing local progress"
        case .ready: "Your path is ready"
        }
    }

    var message: String {
        switch self {
        case .checking: "Reading the lessons already stored on this iPhone."
        case .grammar: "Organizing grammar in a clear teacher-led sequence."
        case .vocabularyA1: "Everyday starter words and visual examples are in place."
        case .vocabularyA2: "Independent everyday language has joined your path."
        case .vocabularyB1: "Exam-ready vocabulary and real-life situations are prepared."
        case .practice: "Connecting quizzes, speaking, listening, reading, and writing."
        case .saving: "Your course stays private and available on this device."
        case .ready: "Opening your next useful learning activity."
        }
    }

    var icon: String {
        switch self {
        case .checking: "doc.text.magnifyingglass"
        case .grammar: "text.book.closed.fill"
        case .vocabularyA1, .vocabularyA2, .vocabularyB1: "rectangle.stack.fill"
        case .practice: "checkmark.seal.fill"
        case .saving: "lock.shield.fill"
        case .ready: "flag.checkered"
        }
    }

    var progress: Double {
        Double(rawValue + 1) / Double(Self.allCases.count)
    }

    func includes(_ level: CEFRLevel) -> Bool {
        switch level {
        case .a1: rawValue >= Self.vocabularyA1.rawValue
        case .a2: rawValue >= Self.vocabularyA2.rawValue
        case .b1: rawValue >= Self.vocabularyB1.rawValue
        }
    }
}

@MainActor
final class ContentLoader {
    static let shared = ContentLoader()

    private init() {}

    func seedIfNeeded(
        modelContext: ModelContext,
        onProgress: (ContentPreparationPhase) -> Void = { _ in }
    ) async throws {
        onProgress(.checking)
        await Task.yield()

        let existingTopics = Dictionary(uniqueKeysWithValues: try modelContext.fetch(FetchDescriptor<GrammarTopic>()).map { ($0.id, $0) })
        let existingVocabulary = Dictionary(uniqueKeysWithValues: try modelContext.fetch(FetchDescriptor<VocabWord>()).map { ($0.id, $0) })
        let existingQuizzes = Dictionary(uniqueKeysWithValues: try modelContext.fetch(FetchDescriptor<QuizQuestion>()).map { ($0.id, $0) })
        let existingProgressIds = Set(try modelContext.fetch(FetchDescriptor<UserProgress>()).map(\.id))
        let existingReviews = try modelContext.fetch(FetchDescriptor<ReviewItem>())
        let existingReviewContentIds = Set(existingReviews.map(\.contentId))

        let grammarDTOs = try loadGrammar()
        let grammarIDs = Set(grammarDTOs.map(\.id))
        grammarDTOs.forEach { dto in
            if let topic = existingTopics[dto.id] {
                topic.level = dto.level.rawValue
                topic.order = dto.order
                topic.title = dto.title
                topic.explanation = dto.explanation
                topic.examplesData = (try? JSONEncoder().encode(dto.examples)) ?? topic.examplesData
                topic.commonMistakes = dto.commonMistakes
                topic.practiceData = (try? JSONEncoder().encode(dto.practice)) ?? topic.practiceData
            } else {
                modelContext.insert(
                    GrammarTopic(
                        id: dto.id,
                        level: dto.level,
                        order: dto.order,
                        title: dto.title,
                        explanation: dto.explanation,
                        examples: dto.examples,
                        commonMistakes: dto.commonMistakes,
                        practice: dto.practice
                    )
                )
            }

            if !existingReviewContentIds.contains(dto.id) {
                modelContext.insert(
                    ReviewItem(
                        id: "review-\(dto.id)",
                        contentId: dto.id,
                        kind: .grammar
                    )
                )
            }
        }
        for topic in existingTopics.values where !grammarIDs.contains(topic.id) {
            modelContext.delete(topic)
        }

        onProgress(.grammar)
        await Task.yield()

        let vocabularyA1 = try loadVocabulary(fileName: "vocab_a1")
        vocabularyA1.forEach {
            syncVocab($0, existingVocabulary: existingVocabulary, existingReviewContentIds: existingReviewContentIds, modelContext: modelContext)
        }
        onProgress(.vocabularyA1)
        await Task.yield()

        let vocabularyA2 = try loadVocabulary(fileName: "vocab_a2")
        vocabularyA2.forEach {
            syncVocab($0, existingVocabulary: existingVocabulary, existingReviewContentIds: existingReviewContentIds, modelContext: modelContext)
        }
        onProgress(.vocabularyA2)
        await Task.yield()

        let vocabularyB1 = try loadVocabulary(fileName: "vocab_b1")
        vocabularyB1.forEach {
            syncVocab($0, existingVocabulary: existingVocabulary, existingReviewContentIds: existingReviewContentIds, modelContext: modelContext)
        }
        onProgress(.vocabularyB1)
        await Task.yield()

        let vocabularyIDs = Set((vocabularyA1 + vocabularyA2 + vocabularyB1).map(\.id))
        for word in existingVocabulary.values where !vocabularyIDs.contains(word.id) {
            modelContext.delete(word)
        }
        let activeReviewContentIDs = grammarIDs.union(vocabularyIDs)
        for review in existingReviews where !activeReviewContentIDs.contains(review.contentId) {
            modelContext.delete(review)
        }

        let quizDTOs = try loadQuizzes()
        let quizIDs = Set(quizDTOs.map(\.id))
        quizDTOs.forEach { dto in
            if let quiz = existingQuizzes[dto.id] {
                quiz.level = dto.level.rawValue
                quiz.unitId = dto.unitId
                quiz.type = dto.type.rawValue
                quiz.skill = dto.skill.rawValue
                quiz.prompt = dto.prompt
                quiz.choices = dto.choices
                quiz.correctAnswer = dto.correctAnswer
                quiz.explanation = dto.explanation
            } else {
                modelContext.insert(
                    QuizQuestion(
                        id: dto.id,
                        level: dto.level,
                        unitId: dto.unitId,
                        type: dto.type,
                        skill: dto.skill,
                        prompt: dto.prompt,
                        choices: dto.choices,
                        correctAnswer: dto.correctAnswer,
                        explanation: dto.explanation
                    )
                )
            }
        }
        for quiz in existingQuizzes.values where !quizIDs.contains(quiz.id) {
            modelContext.delete(quiz)
        }

        onProgress(.practice)
        await Task.yield()

        for level in CEFRLevel.allCases {
            let id = "progress-\(level.rawValue.lowercased())"
            guard !existingProgressIds.contains(id) else { continue }
            modelContext.insert(UserProgress(id: id, level: level))
        }

        onProgress(.saving)
        await Task.yield()
        try modelContext.save()

        onProgress(.ready)
        await Task.yield()
    }

    func loadGrammar() throws -> [GrammarTopicDTO] {
        try decode([GrammarTopicDTO].self, fileName: "grammar")
    }

    func loadVocabulary(fileName: String) throws -> [VocabWordDTO] {
        try decode([VocabWordDTO].self, fileName: fileName)
    }

    func loadQuizzes() throws -> [QuizQuestionDTO] {
        let explicit = try decode([QuizQuestionDTO].self, fileName: "quizzes")
        let vocabulary = try allVocabulary()
        return CurriculumFactory.quizzes(explicit: explicit, grammar: try loadGrammar(), vocabulary: vocabulary)
    }

    func loadLessons() throws -> [CompleteLessonDTO] {
        let explicit = try decode([CompleteLessonDTO].self, fileName: "lessons")
        return CurriculumFactory.lessons(explicit: explicit, grammar: try loadGrammar(), vocabulary: try allVocabulary())
    }

    func loadPracticalMissions() throws -> [PracticalMissionDTO] {
        try decode([PracticalMissionDTO].self, fileName: "practical_missions")
    }

    func loadEverydayPhrasebook() throws -> [EverydayPhraseCategoryDTO] {
        try decode([EverydayPhraseCategoryDTO].self, fileName: "everyday_phrases")
    }

    func allVocabulary() throws -> [VocabWordDTO] {
        try ["vocab_a1", "vocab_a2", "vocab_b1"].flatMap { try loadVocabulary(fileName: $0) }
    }

    private func syncVocab(
        _ dto: VocabWordDTO,
        existingVocabulary: [String: VocabWord],
        existingReviewContentIds: Set<String>,
        modelContext: ModelContext
    ) {
        if let word = existingVocabulary[dto.id] {
            word.level = dto.level.rawValue
            word.theme = dto.theme
            word.german = dto.german
            word.article = dto.article
            word.plural = dto.plural
            word.english = dto.english
            word.exampleSentence = dto.exampleSentence
            word.exampleTranslation = dto.exampleTranslation
            word.ttsText = dto.ttsText
            word.difficultyTag = dto.difficultyTag
        } else {
            modelContext.insert(
                VocabWord(
                    id: dto.id,
                    level: dto.level,
                    theme: dto.theme,
                    german: dto.german,
                    article: dto.article,
                    plural: dto.plural,
                    english: dto.english,
                    exampleSentence: dto.exampleSentence,
                    exampleTranslation: dto.exampleTranslation,
                    ttsText: dto.ttsText,
                    difficultyTag: dto.difficultyTag
                )
            )
        }

        if !existingReviewContentIds.contains(dto.id) {
            modelContext.insert(
                ReviewItem(
                    id: "review-\(dto.id)",
                    contentId: dto.id,
                    kind: .vocabulary
                )
            )
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, fileName: String) throws -> T {
        let url: URL?
        url = AdminContentManager.shared.activeURL(for: fileName)
            ?? Bundle.main.url(forResource: fileName, withExtension: "json")
        guard let url else {
            throw ContentLoaderError.missingResource(fileName)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

struct AdminManagedContentFile: Identifiable, Hashable {
    let fileName: String
    let title: String
    let detail: String

    var id: String { fileName }
}

@MainActor
final class AdminContentManager: ObservableObject {
    static let shared = AdminContentManager()

    static let supportedFiles: [AdminManagedContentFile] = [
        .init(fileName: "grammar", title: "Grammar", detail: "Rules, examples, mistakes, and exercises"),
        .init(fileName: "vocab_a1", title: "A1 vocabulary", detail: "Words, articles, plurals, examples, and audio text"),
        .init(fileName: "vocab_a2", title: "A2 vocabulary", detail: "Words, articles, plurals, examples, and audio text"),
        .init(fileName: "vocab_b1", title: "B1 vocabulary", detail: "Words, articles, plurals, examples, and audio text"),
        .init(fileName: "lessons", title: "Lessons", detail: "Course sequence, scenarios, practice, and recap"),
        .init(fileName: "quizzes", title: "Quizzes", detail: "Questions, choices, answers, and explanations"),
        .init(fileName: "practical_missions", title: "Real-life missions", detail: "Role-play scenarios and model responses"),
        .init(fileName: "everyday_phrases", title: "Everyday phrases", detail: "Phrasebook categories and phrases")
    ]

    @Published private(set) var revision = UUID()

    private let fileManager = FileManager.default

    private init() {}

    func activeURL(for fileName: String) -> URL? {
        let url = activeDirectory.appendingPathComponent("\(fileName).json")
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    func hasOverride(for fileName: String) -> Bool {
        activeURL(for: fileName) != nil
    }

    func hasBackup(for fileName: String) -> Bool {
        fileManager.fileExists(atPath: backupURL(for: fileName).path)
    }

    func install(from sourceURL: URL) throws -> AdminManagedContentFile {
        let imported = try readImport(from: sourceURL)
        try install(data: imported.data, fileName: imported.file.fileName)
        return imported.file
    }

    func readImport(from sourceURL: URL) throws -> (file: AdminManagedContentFile, data: Data) {
        let fileName = sourceURL.deletingPathExtension().lastPathComponent
        guard sourceURL.pathExtension.lowercased() == "json",
              let descriptor = Self.supportedFiles.first(where: { $0.fileName == fileName })
        else {
            throw AdminContentError.unsupportedFile(sourceURL.lastPathComponent)
        }

        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed { sourceURL.stopAccessingSecurityScopedResource() }
        }

        let data = try Data(contentsOf: sourceURL)
        try validate(data, fileName: fileName)
        return (descriptor, data)
    }

    func install(data: Data, fileName: String) throws {
        try validate(data, fileName: fileName)
        try prepareDirectories()

        let destination = activeDirectory.appendingPathComponent("\(fileName).json")
        if fileManager.fileExists(atPath: destination.path) {
            try replaceBackup(with: destination, fileName: fileName)
        }
        try data.write(to: destination, options: .atomic)
        revision = UUID()
    }

    func backupData(for fileName: String) throws -> Data {
        let url = backupURL(for: fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            throw AdminContentError.noBackup(fileName)
        }
        let data = try Data(contentsOf: url)
        try validate(data, fileName: fileName)
        return data
    }

    func restoreBundledContent(for fileName: String) throws {
        guard let active = activeURL(for: fileName) else { return }
        try prepareDirectories()
        try replaceBackup(with: active, fileName: fileName)
        try fileManager.removeItem(at: active)
        revision = UUID()
    }

    func rollback(for fileName: String) throws {
        let backup = backupURL(for: fileName)
        guard fileManager.fileExists(atPath: backup.path) else {
            throw AdminContentError.noBackup(fileName)
        }
        try prepareDirectories()
        let active = activeDirectory.appendingPathComponent("\(fileName).json")
        if fileManager.fileExists(atPath: active.path) {
            try fileManager.removeItem(at: active)
        }
        try fileManager.moveItem(at: backup, to: active)
        revision = UUID()
    }

    private var rootDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("DeutschB1Coach/OwnerContent", isDirectory: true)
    }

    private var activeDirectory: URL {
        rootDirectory.appendingPathComponent("Active", isDirectory: true)
    }

    private var backupDirectory: URL {
        rootDirectory.appendingPathComponent("Backup", isDirectory: true)
    }

    private func backupURL(for fileName: String) -> URL {
        backupDirectory.appendingPathComponent("\(fileName).json")
    }

    private func prepareDirectories() throws {
        try fileManager.createDirectory(at: activeDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
    }

    private func replaceBackup(with source: URL, fileName: String) throws {
        let backup = backupURL(for: fileName)
        if fileManager.fileExists(atPath: backup.path) {
            try fileManager.removeItem(at: backup)
        }
        try fileManager.copyItem(at: source, to: backup)
    }

    func validate(_ data: Data, fileName: String) throws {
        let decoder = JSONDecoder()
        switch fileName {
        case "grammar":
            try validateIDs(
                try decoder.decode([GrammarTopicDTO].self, from: data),
                fileName: fileName,
                id: \.id
            )
        case "vocab_a1", "vocab_a2", "vocab_b1":
            try validateIDs(
                try decoder.decode([VocabWordDTO].self, from: data),
                fileName: fileName,
                id: \.id
            )
        case "lessons":
            try validateIDs(
                try decoder.decode([CompleteLessonDTO].self, from: data),
                fileName: fileName,
                id: \.id
            )
        case "quizzes":
            try validateIDs(
                try decoder.decode([QuizQuestionDTO].self, from: data),
                fileName: fileName,
                id: \.id
            )
        case "practical_missions":
            try validateIDs(
                try decoder.decode([PracticalMissionDTO].self, from: data),
                fileName: fileName,
                id: \.id
            )
        case "everyday_phrases":
            try validateIDs(
                try decoder.decode([EverydayPhraseCategoryDTO].self, from: data),
                fileName: fileName,
                id: \.id
            )
        default:
            throw AdminContentError.unsupportedFile(fileName)
        }
    }

    private func validateIDs<T>(
        _ items: [T],
        fileName: String,
        id: KeyPath<T, String>
    ) throws {
        guard !items.isEmpty else {
            throw AdminContentError.emptyContent(fileName)
        }
        guard Set(items.map { $0[keyPath: id] }).count == items.count else {
            throw AdminContentError.duplicateIDs(fileName)
        }
    }
}

struct LiveContentConfiguration: Equatable {
    let baseURL: URL
    let publicAPIKey: String

    static let productionBaseURL = URL(
        string: "https://example.invalid"
    )!

    static func current(bundle: Bundle = .main) -> LiveContentConfiguration? {
        let rawURL = bundle.object(forInfoDictionaryKey: "LiveContentBaseURL") as? String
        let rawKey = bundle.object(forInfoDictionaryKey: "LiveContentAnonKey") as? String ?? ""

        let configuredURL = rawURL?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let urlValue = configuredURL.isEmpty ? productionBaseURL.absoluteString : configuredURL
        let keyValue = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !urlValue.isEmpty,
              let baseURL = URL(string: urlValue),
              let scheme = baseURL.scheme?.lowercased(),
              scheme == "https"
        else { return nil }

        return LiveContentConfiguration(baseURL: baseURL, publicAPIKey: keyValue)
    }
}

private struct LiveContentManifestRecord: Decodable {
    let fileName: String
    let version: Int64
    let sha256: String
    let minimumBuild: Int

    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
        case version
        case sha256
        case minimumBuild = "minimum_build"
    }
}

private struct LiveContentRecord: Decodable {
    let fileName: String
    let version: Int64
    let payloadBase64: String
    let sha256: String
    let minimumBuild: Int

    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
        case version
        case payloadBase64 = "payload_base64"
        case sha256
        case minimumBuild = "minimum_build"
    }
}

@MainActor
final class LiveContentService: ObservableObject {
    static let shared = LiveContentService()

    @Published private(set) var isRefreshing = false
    @Published private(set) var publishedVersions: [String: Int64] = [:]
    @Published private(set) var lastRefreshDate: Date?

    var isConfigured: Bool { configuration != nil }

    private let configuration: LiveContentConfiguration?
    private let session: URLSession
    private let defaults: UserDefaults

    init(
        configuration: LiveContentConfiguration? = .current(),
        session: URLSession = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.configuration = configuration
        self.session = session
        self.defaults = defaults
    }

    @discardableResult
    func refreshPublishedContent() async throws -> Int {
        guard let configuration else { return 0 }
        guard !isRefreshing else { return 0 }
        isRefreshing = true
        defer { isRefreshing = false }

        let request = try makeRequest(
            configuration: configuration,
            path: "rest/v1/app_content",
            queryItems: [
                URLQueryItem(
                    name: "select",
                    value: "file_name,version,sha256,minimum_build"
                )
            ]
        )
        let responseData = try await send(request)
        let manifest = try JSONDecoder().decode([LiveContentManifestRecord].self, from: responseData)
        let supportedNames = Set(AdminContentManager.supportedFiles.map(\.fileName))
        let build = currentBuildNumber
        let eligibleManifest = manifest.filter {
            supportedNames.contains($0.fileName) && $0.minimumBuild <= build && $0.version > 0
        }
        let manifestByName = Dictionary(uniqueKeysWithValues: eligibleManifest.map { ($0.fileName, $0) })

        let changedNames = eligibleManifest.compactMap { record -> String? in
            let installedVersion = defaults.object(forKey: versionKey(for: record.fileName)) as? NSNumber
            let hasMatchingCache = installedVersion?.int64Value == record.version
                && AdminContentManager.shared.hasOverride(for: record.fileName)
            return hasMatchingCache ? nil : record.fileName
        }

        var records: [LiveContentRecord] = []
        if !changedNames.isEmpty {
            let payloadRequest = try makeRequest(
                configuration: configuration,
                path: "rest/v1/app_content",
                queryItems: [
                    URLQueryItem(
                        name: "select",
                        value: "file_name,version,payload_base64,sha256,minimum_build"
                    ),
                    URLQueryItem(
                        name: "file_name",
                        value: "in.(\(changedNames.joined(separator: ",")))"
                    )
                ]
            )
            records = try JSONDecoder().decode(
                [LiveContentRecord].self,
                from: try await send(payloadRequest)
            )
        }

        var prepared: [(record: LiveContentRecord, data: Data)] = []
        for record in records {
            guard let metadata = manifestByName[record.fileName],
                  metadata.version == record.version,
                  metadata.sha256 == record.sha256,
                  metadata.minimumBuild == record.minimumBuild
            else {
                throw LiveContentError.invalidPayload(record.fileName)
            }
            guard record.version > 0,
                  let data = Data(base64Encoded: record.payloadBase64)
            else {
                throw LiveContentError.invalidPayload(record.fileName)
            }
            guard Self.digest(for: data) == record.sha256.lowercased() else {
                throw LiveContentError.integrityCheckFailed(record.fileName)
            }
            try AdminContentManager.shared.validate(data, fileName: record.fileName)
            prepared.append((record, data))
        }
        guard Set(prepared.map(\.record.fileName)) == Set(changedNames) else {
            throw LiveContentError.invalidResponse
        }

        var changes = 0
        let availableNames = Set(eligibleManifest.map(\.fileName))
        for file in AdminContentManager.supportedFiles {
            let key = versionKey(for: file.fileName)
            if defaults.object(forKey: key) != nil, !availableNames.contains(file.fileName) {
                try AdminContentManager.shared.restoreBundledContent(for: file.fileName)
                defaults.removeObject(forKey: key)
                changes += 1
            }
        }

        for item in prepared {
            let installedVersion = defaults.object(forKey: versionKey(for: item.record.fileName)) as? NSNumber
            let hasMatchingCache = installedVersion?.int64Value == item.record.version
                && AdminContentManager.shared.hasOverride(for: item.record.fileName)
            guard !hasMatchingCache else { continue }

            try AdminContentManager.shared.install(data: item.data, fileName: item.record.fileName)
            defaults.set(item.record.version, forKey: versionKey(for: item.record.fileName))
            changes += 1
        }

        publishedVersions = Dictionary(uniqueKeysWithValues: eligibleManifest.map { ($0.fileName, $0.version) })
        lastRefreshDate = .now
        return changes
    }

    private var currentBuildNumber: Int {
        let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return Int(value ?? "1") ?? 1
    }

    private func versionKey(for fileName: String) -> String {
        "liveContent.version.\(fileName)"
    }

    private func makeRequest(
        configuration: LiveContentConfiguration,
        path: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        let endpoint = configuration.baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw LiveContentError.invalidConfiguration
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw LiveContentError.invalidConfiguration }

        var request = URLRequest(url: url, timeoutInterval: 12)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if !configuration.publicAPIKey.isEmpty {
            request.setValue(configuration.publicAPIKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(configuration.publicAPIKey)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LiveContentError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8)
            throw LiveContentError.server(status: httpResponse.statusCode, message: serverMessage)
        }
        return data
    }

    private static func digest(for data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

enum AdminContentError: LocalizedError {
    case unsupportedFile(String)
    case emptyContent(String)
    case duplicateIDs(String)
    case noBackup(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedFile(let file):
            "Unsupported file: \(file). Use one of the exact Content Studio filenames."
        case .emptyContent(let file):
            "\(file).json contains no content."
        case .duplicateIDs(let file):
            "\(file).json contains duplicate IDs."
        case .noBackup(let file):
            "No previous version of \(file).json is available."
        }
    }
}

enum LiveContentError: LocalizedError {
    case notConfigured
    case invalidConfiguration
    case invalidPayload(String)
    case integrityCheckFailed(String)
    case invalidResponse
    case server(status: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .notConfigured, .invalidConfiguration:
            return "Live Content is not configured in this app build."
        case .invalidPayload(let file):
            return "The live payload for \(file).json is not valid."
        case .integrityCheckFailed(let file):
            return "The integrity check failed for \(file).json. The existing course was kept."
        case .invalidResponse:
            return "The content server returned an invalid response."
        case .server(let status, let message):
            let detail = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return detail.isEmpty
                ? "The content server returned error \(status)."
                : "The content server returned error \(status): \(detail)"
        }
    }
}

enum ContentLoaderError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return "Missing bundled content resource: \(name).json"
        }
    }
}
