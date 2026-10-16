import Foundation

struct OrientationCatalogueSource: Codable, Hashable {
    let title: String
    let publisher: String
    let date: String
    let url: String
}

private struct OrientationQuestionPayload: Decodable {
    let version: Int
    let source: OrientationCatalogueSource
    let general: [OrientationQuestion]
    let states: [String: [OrientationQuestion]]

    static let empty = OrientationQuestionPayload(
        version: 0,
        source: OrientationCatalogueSource(title: "", publisher: "", date: "", url: ""),
        general: [],
        states: [:]
    )
}

enum OrientationQuestionRepository {
    private static let loadResult: Result<OrientationQuestionPayload, Error> = Result {
        guard let url = Bundle.main.url(
            forResource: "orientation_questions",
            withExtension: "json"
        ) else {
            throw OrientationQuestionRepositoryError.missingResource
        }
        let payload = try JSONDecoder().decode(
            OrientationQuestionPayload.self,
            from: Data(contentsOf: url)
        )
        try validate(payload)
        return payload
    }

    private static let payload = (try? loadResult.get()) ?? .empty

    static var generalQuestions: [OrientationQuestion] { payload.general }
    static var source: OrientationCatalogueSource { payload.source }

    static var loadErrorDescription: String? {
        guard case let .failure(error) = loadResult else { return nil }
        return error.localizedDescription
    }

    static func questions(for state: GermanFederalState) -> [OrientationQuestion] {
        payload.states[state.rawValue] ?? []
    }

    static var allQuestions: [OrientationQuestion] {
        payload.general + GermanFederalState.allCases.flatMap { questions(for: $0) }
    }

    private static func validate(_ payload: OrientationQuestionPayload) throws {
        guard payload.general.count == 300 else {
            throw OrientationQuestionRepositoryError.invalidGeneralCount(payload.general.count)
        }

        for state in GermanFederalState.allCases {
            let questions = payload.states[state.rawValue] ?? []
            guard questions.count == 10 else {
                throw OrientationQuestionRepositoryError.invalidStateCount(state.name, questions.count)
            }
        }

        let questions = payload.general + payload.states.values.flatMap { $0 }
        if let invalid = questions.first(where: { !$0.hasStandardChoiceFormat }) {
            throw OrientationQuestionRepositoryError.invalidQuestionFormat(invalid.id)
        }
    }
}

private enum OrientationQuestionRepositoryError: LocalizedError {
    case missingResource
    case invalidGeneralCount(Int)
    case invalidStateCount(String, Int)
    case invalidQuestionFormat(String)

    var errorDescription: String? {
        switch self {
        case .missingResource:
            "Der BAMF-Fragenkatalog ist in dieser App-Version nicht verfügbar."
        case let .invalidGeneralCount(count):
            "Der BAMF-Fragenkatalog enthält \(count) statt 300 allgemeine Fragen."
        case let .invalidStateCount(state, count):
            "Der Fragenkatalog für \(state) enthält \(count) statt 10 Fragen."
        case let .invalidQuestionFormat(id):
            "Die Frage \(id) hat nicht genau vier gültige Antwortmöglichkeiten."
        }
    }
}
