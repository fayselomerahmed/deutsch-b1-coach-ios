import Foundation

struct SimplifiedExplanationStep: Hashable {
    let title: String
    let detail: String
}

struct SimplifiedExplanation: Hashable {
    let title: String
    let oneLine: String
    let analogy: String
    let steps: [SimplifiedExplanationStep]
    let modelGerman: String?
    let modelMeaning: String?
    let checkQuestion: String
    let checkAnswer: String
    let icon: String
    let protectedGerman: [String]
}

enum SimplifiedExplanationCatalog {
    static var supportedGrammarTopicIDs: Set<String> { Set(grammarIdeas.keys) }
    static var supportedVocabularyThemes: Set<String> { Set(vocabularyThemeIdeas.keys) }

    static func grammar(_ topic: GrammarTopic) -> SimplifiedExplanation {
        let idea = grammarIdeas[topic.id]
            ?? "Use this pattern to make one part of your message clearer."
        let model = topic.examples.first
        return SimplifiedExplanation(
            title: "\(topic.title), made simple",
            oneLine: idea,
            analogy: grammarAnalogy(topicID: topic.id),
            steps: [
                .init(
                    title: "Know the message",
                    detail: model.map { "First think: \($0.english)" }
                        ?? "First decide the one message you want to communicate."
                ),
                .init(
                    title: "Copy one safe shape",
                    detail: model.map { "Use this as your frame: \($0.german)" }
                        ?? "Copy one correct example before changing anything."
                ),
                .init(
                    title: "Change one piece",
                    detail: "Change only a person, time, place, or object. Keep the rest of the sentence shape."
                )
            ],
            modelGerman: model?.german,
            modelMeaning: model?.english,
            checkQuestion: "What is the one idea to remember?",
            checkAnswer: idea,
            icon: "lightbulb.max.fill",
            protectedGerman: protectedGrammarTerms
                + topic.examples.map(\.german)
                + topic.practice.map(\.answer)
        )
    }

    static func vocabularyTheme(
        level: CEFRLevel,
        theme: String,
        words: [VocabWord]
    ) -> SimplifiedExplanation {
        let idea = vocabularyThemeIdeas[theme]
            ?? "These words help you communicate in one familiar everyday situation."
        let model = words.first
        return SimplifiedExplanation(
            title: "\(theme), made simple",
            oneLine: idea,
            analogy: "Think of this topic as one small scene. Learn the people, things, and actions you can point to inside that scene.",
            steps: [
                .init(title: "Start with five", detail: "Learn five useful words first. A small group is easier to remember than the whole list."),
                .init(title: "See and say", detail: "Look at each picture, say the German word aloud, then check the meaning."),
                .init(title: "Build one moment", detail: "Use two of the words in one sentence about a real \(theme.lowercased()) situation.")
            ],
            modelGerman: model?.exampleSentence,
            modelMeaning: model?.exampleMeaning,
            checkQuestion: "What should you do before learning the whole \(level.rawValue) word list?",
            checkAnswer: "Start with five useful words, picture them, say them, and use two in one real sentence.",
            icon: "photo.on.rectangle.angled",
            protectedGerman: words.flatMap {
                [$0.german, $0.article, $0.plural].compactMap { $0 }
            }
        )
    }

    static func vocabularyWord(_ word: VocabWord) -> SimplifiedExplanation {
        let german = displayGerman(word)
        let formNote: String
        if let article = word.article, let plural = word.plural, !plural.isEmpty {
            formNote = "Treat \(article) + the noun as one word-picture. The plural is \(plural)."
        } else if let article = word.article {
            formNote = "Remember the article \(article) together with the noun."
        } else {
            formNote = "Connect the sound directly to one action, quality, or situation."
        }
        return SimplifiedExplanation(
            title: "\(german), made simple",
            oneLine: "\(german) simply means “\(word.english)”.",
            analogy: "Imagine a clear picture, place the German word on it like a label, then say the label aloud.",
            steps: [
                .init(title: "Picture it", detail: "See “\(word.english)” in your mind before translating anything else."),
                .init(title: "Say the whole unit", detail: formNote),
                .init(title: "Use it once", detail: "Read the model sentence, then change one detail to make it about your life.")
            ],
            modelGerman: word.exampleSentence,
            modelMeaning: word.exampleMeaning,
            checkQuestion: "What does \(german) mean?",
            checkAnswer: word.english,
            icon: "character.book.closed.fill",
            protectedGerman: [
                german,
                word.german,
                word.article,
                word.plural,
            ].compactMap { $0 }
        )
    }

    private static let grammarIdeas: [String: String] = [
        "a1-alphabet-pronunciation": "Connect each German letter to its sound, then use the sound to spell names and familiar words aloud.",
        "a1-pronouns": "Use a small replacement word such as ich, du, or sie instead of repeating a person's name.",
        "a1-formal-address": "Use Sie for polite distance and du for familiar relationships.",
        "a1-sein-haben": "Use sein for who or how something is, and haben for what someone has.",
        "a1-present-tense": "The verb ending changes to show who is doing the action now.",
        "a1-word-order": "In a normal statement, the changed verb sits in position two.",
        "a1-questions": "Start with a question word, or put the verb first for a yes-or-no question.",
        "a1-articles-nominative": "Use der, die, or das with the person or thing doing the action.",
        "a1-plurals": "German nouns use different plural shapes, so learn each plural with its noun.",
        "a1-adjectives-predicative": "After sein, the adjective stays simple and gets no extra ending.",
        "a1-comparative-basics": "Add -er to compare two things, and use als before the second thing.",
        "a1-accusative": "The accusative marks the person or thing directly receiving the action.",
        "a1-accusative-pronouns": "Replace the direct object with mich, dich, ihn, sie, es, uns, euch, or sie.",
        "a1-dative-pronouns": "Use mir, dir, ihm, ihr, uns, euch, or ihnen for the receiver or beneficiary.",
        "a1-negation": "Use kein before a noun and nicht to say an action or description is not true.",
        "a1-possessives": "Mein, dein, and the other possessives show who something belongs to.",
        "a1-modals": "A modal verb adds ability, need, permission, or desire; the action verb moves to the end.",
        "a1-imperative": "Use the verb as a direct instruction or request to another person.",
        "a1-separable-verbs": "In a main sentence, the first part of a separable verb moves to the end.",
        "a1-coordination": "Und, aber, oder, and denn join two ideas without changing normal word order.",
        "a1-preposition-contractions": "Common preposition and article pairs shrink into forms such as im, am, and zum.",
        "a1-time-expressions": "Put a time word in the sentence to say when something happens.",
        "a1-prepositions": "A preposition connects a thing to a place, time, direction, or relationship.",
        "a1-place-direction": "Use wo for location and wohin for movement toward a destination.",
        "a1-perfect-basic": "Use haben or sein plus a past form to talk about a completed event.",
        "a1-past-sein-haben": "Use war and hatte for simple past states and possession.",
        "a2-perfect": "Build the spoken past with haben or sein and put the past participle at the end.",
        "a2-participle-formation": "Make many past participles with ge- plus the verb stem plus -t or -en.",
        "a2-preterite": "Use simple past forms especially for sein, haben, modal verbs, and written stories.",
        "a2-werden-changes": "Use werden to say that a person or situation is changing into something new.",
        "a2-modal-past": "Use konnte, musste, durfte, wollte, or sollte to express modal meaning in the past.",
        "a2-dative": "The dative often marks the receiver and follows certain verbs and prepositions.",
        "a2-object-pronouns": "Use short pronouns instead of repeating people and things already known.",
        "a2-double-object-order": "With two nouns, dative usually comes before accusative; short pronouns usually come first.",
        "a2-two-way-prepositions": "Use accusative for movement to a place and dative for a fixed location.",
        "a2-n-declension-basic": "Some masculine nouns add -n or -en in every case except nominative singular.",
        "a2-verbs-prepositions": "Some verbs always travel with one fixed preposition, so learn the pair together.",
        "a2-pronominal-adverbs": "Use da- plus a preposition for things and wo- plus a preposition to ask about things.",
        "a2-reflexive": "A reflexive pronoun sends the action back to the person doing it.",
        "a2-reflexive-dative": "Use a dative reflexive pronoun when another accusative object is also in the sentence.",
        "a2-indefinite-pronouns": "Words such as jemand, niemand, etwas, and nichts refer without naming exactly who or what.",
        "a2-adjective-endings": "The adjective ending helps show gender, number, and case before a noun.",
        "a2-comparative": "Use comparative forms for differences and superlative forms for the highest degree.",
        "a2-time-manner-place": "A useful neutral order is time, manner, then place.",
        "a2-infinitive-zu": "Use zu plus an infinitive to add a second action without a new subject.",
        "a2-purpose": "Use um ... zu when the same person performs an action for a purpose.",
        "a2-subordinate": "A subordinating word opens a dependent clause and sends its changed verb to the end.",
        "a2-causal-connectors": "Use weil or da for a reason and deshalb or deswegen for the result.",
        "a2-temporal-clauses": "Use als for one past time, wenn for repeated or present times, and bevor or nachdem for order.",
        "a2-indirect-questions": "Turn a question into part of a sentence and place its verb at the end.",
        "a2-relative-basic": "A relative clause adds information about a noun and puts its verb at the end.",
        "b1-past-narrative": "Choose past forms consistently so the reader can follow the main events of a story.",
        "b1-plusquamperfekt": "Use hatte or war plus a participle for an event that happened before another past event.",
        "b1-temporal-connectors": "Use time connectors to make the exact order and overlap of events clear.",
        "b1-connectors": "Choose a connector that shows whether the next idea is a reason, result, contrast, or addition.",
        "b1-concessive-alternatives": "Show that an obstacle exists but does not change the result.",
        "b1-concessive": "Use obwohl for a surprising contrast and trotzdem for the result that still happens.",
        "b1-relative": "Use a relative clause to identify or describe a noun without starting a new sentence.",
        "b1-relative-wo-was": "Use wo for a place and was after broad words such as alles, nichts, or das.",
        "b1-konjunktiv-ii": "Use würde, hätte, wäre, or special forms to make wishes, polite requests, and unreal ideas.",
        "b1-conditionals": "A conditional sentence links a condition with the result that depends on it.",
        "b1-passive": "The passive focuses on the action or result instead of the person doing it.",
        "b1-alternatives": "Use paired connectors to present two linked choices, additions, or contrasts.",
        "b1-passive-modal-verbs": "Combine a modal verb with passive meaning when an action can, must, or should be done.",
        "b1-genitive": "The genitive shows that one noun belongs or relates closely to another noun.",
        "b1-adjective-endings": "Use the article and case as clues for the adjective ending before a noun.",
        "b1-n-declension": "Keep the extra -n or -en on weak masculine nouns outside nominative singular.",
        "b1-participles-adjectives": "Use a participle like an adjective to pack an action or result before a noun.",
        "b1-nominalization": "Turn an action or quality into a noun for denser, more formal language.",
        "b1-collocations": "Some words naturally belong together, so learn the whole phrase as one unit.",
        "b1-modal-particles": "Small words such as doch, mal, eben, and wohl change the speaker's tone, not the basic fact.",
        "b1-extended-infinitives": "Use an infinitive group to express purpose, alternatives, or accompanying actions compactly.",
        "b1-result-manner": "Use result and manner clauses to explain how something happens or what follows from it.",
        "b1-indirect-speech": "Report another person's information while showing that the words originally came from them.",
        "b1-future": "Use werden plus an infinitive for future plans, predictions, or assumptions.",
        "b1-konjunktiv-past": "Use hätte or wäre plus a participle to imagine a different past that cannot now be changed."
    ]

    private static let protectedGrammarTerms = [
        "Nominativ", "Akkusativ", "Dativ", "Genitiv",
        "Perfekt", "Präteritum", "Plusquamperfekt", "Passiv",
        "Konjunktiv II", "Partizip II", "Relativsatz", "N-Deklination",
        "Nominalisierung", "sein", "haben", "werden",
        "ich", "du", "er", "sie", "es", "wir", "ihr", "Sie",
        "mich", "dich", "ihn", "uns", "euch", "ihnen",
        "mir", "dir", "ihm", "ihnen",
        "der", "die", "das", "den", "dem", "des",
        "ein", "eine", "einen", "einem", "einer", "eines",
        "kein", "keine", "keinen", "keinem", "keiner", "keines",
        "nicht", "weil", "dass", "wenn", "obwohl", "trotzdem",
        "damit", "um ... zu", "als", "bevor", "nachdem",
        "indem", "sodass", "ohne ... zu", "statt ... zu",
        "doch", "mal", "eben", "wohl",
    ]

    private static let vocabularyThemeIdeas: [String: String] = [
        "Menschen": "These words help you identify people, introduce yourself, and ask basic personal questions.",
        "Familie": "These words help you name family relationships and talk about the people close to you.",
        "Alltag": "These words help you describe the ordinary actions that make up your day.",
        "Zeit": "These words help you arrange times, understand schedules, and say when something happens.",
        "Wohnen": "These words help you describe a home, understand housing details, and report problems.",
        "Essen": "These words help you choose, prepare, order, and talk about food and drink.",
        "Einkaufen": "These words help you find products, understand prices, pay, and solve purchase problems.",
        "Stadt": "These words help you find places and handle common situations around town.",
        "Verkehr": "These words help you plan a route, use transport, and understand travel information.",
        "Gesundheit": "These words help you describe your body, symptoms, appointments, and medical advice.",
        "Arbeit": "These words help you discuss jobs, tasks, schedules, colleagues, and workplace needs.",
        "Lernen": "These words help you participate in a course and explain how you learn best.",
        "Eigenschaften": "These words help you describe what people, things, and situations are like.",
        "Gefühle": "These words help you name emotions and explain how a situation affects you.",
        "Wetter": "These words help you understand forecasts and describe outdoor conditions.",
        "Kommunikation": "These words help you exchange information, clarify meaning, and respond to other people.",
        "Ämter": "These words help you handle appointments, forms, documents, and requests at public offices.",
        "Freizeit": "These words help you talk about interests, invitations, plans, and social activities.",
        "Reisen": "These words help you plan trips, book services, and solve travel difficulties.",
        "Konnektoren": "These linking words show how one idea connects to the next.",
        "Umwelt": "These words help you discuss nature, resources, waste, climate, and practical choices.",
        "Behörden": "These words help you understand administrative procedures, responsibilities, and formal communication.",
        "Bildung": "These words help you discuss schools, qualifications, training, and learning opportunities.",
        "Medien": "These words help you understand messages, news, digital services, and information sources.",
        "Gesellschaft": "These words help you discuss how people live together, participate, and handle differences.",
        "Konflikte": "These words help you describe a disagreement and work toward a fair solution.",
        "Argumentation": "These words help you state a position, give reasons, and respond to another viewpoint.",
        "Prüfung": "These words help you understand B1 tasks, instructions, strategies, and feedback."
    ]

    private static func grammarAnalogy(topicID: String) -> String {
        if topicID.contains("passive") {
            return "Think of a camera. The passive points the camera at the action, not the person doing it."
        }
        if topicID.contains("relative") {
            return "Think of a paperclip. The relative clause clips extra information onto one noun."
        }
        if topicID.contains("konjunktiv") || topicID.contains("conditional") {
            return "Think of a thought bubble. It contains a wish, polite possibility, or imagined reality."
        }
        if topicID.contains("perfect") || topicID.contains("past") || topicID.contains("preterite") || topicID.contains("future") || topicID.contains("temporal") {
            return "Think of a timeline. First place the event in time, then choose the grammar shape that belongs there."
        }
        if topicID.contains("dative") || topicID.contains("accusative") || topicID.contains("genitive") || topicID.contains("declension") {
            return "Think of a small play: one actor acts, another receives, and the word endings show each role."
        }
        if topicID.contains("adjective") || topicID.contains("article") || topicID.contains("plural") {
            return "Think of matching clothes. The article, noun, and ending give clues that should fit together."
        }
        if topicID.contains("preposition") || topicID.contains("place") || topicID.contains("space") {
            return "Think of a map. The small linking word shows location, direction, time, or relationship."
        }
        if topicID.contains("connector") || topicID.contains("subordinate") || topicID.contains("question") || topicID.contains("order") {
            return "Think of a sentence train. Each part has a position, and the connector can change where the verb carriage goes."
        }
        if topicID.contains("pronoun") || topicID.contains("possessive") || topicID.contains("reflexive") {
            return "Think of name labels. The short word tells us which person or thing the sentence points to."
        }
        return "Think of grammar as a reusable sentence mold: keep the shape and replace only the details you need."
    }

    private static func displayGerman(_ word: VocabWord) -> String {
        guard let article = word.article, !article.isEmpty else { return word.german }
        return word.german.lowercased().hasPrefix(article.lowercased() + " ")
            ? word.german
            : "\(article) \(word.german)"
    }
}
