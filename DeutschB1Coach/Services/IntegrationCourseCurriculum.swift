import Foundation

enum IntegrationActionField: String, CaseIterable, Identifiable, Hashable {
    case migrationAndIdentity
    case feelingsOpinions
    case conflictResolution
    case socialContacts
    case languageLearning
    case authorities
    case work
    case jobSearch
    case educationTraining
    case bankingInsurance
    case childcareEducation
    case shopping
    case health
    case mediaUse
    case mobility
    case classroom
    case housing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .migrationAndIdentity: "Migration and identity"
        case .feelingsOpinions: "Feelings and opinions"
        case .conflictResolution: "Disagreement and conflict"
        case .socialContacts: "Social contacts"
        case .languageLearning: "Learning German"
        case .authorities: "Public offices"
        case .work: "Work"
        case .jobSearch: "Job search"
        case .educationTraining: "Education and training"
        case .bankingInsurance: "Banks and insurance"
        case .childcareEducation: "Childcare and school"
        case .shopping: "Shopping and services"
        case .health: "Health"
        case .mediaUse: "Media use"
        case .mobility: "Mobility"
        case .classroom: "Course participation"
        case .housing: "Housing"
        }
    }

    var icon: String {
        switch self {
        case .migrationAndIdentity: "person.text.rectangle.fill"
        case .feelingsOpinions: "heart.text.square.fill"
        case .conflictResolution: "bubble.left.and.exclamationmark.bubble.right.fill"
        case .socialContacts: "person.2.fill"
        case .languageLearning: "character.book.closed.fill"
        case .authorities: "building.columns.fill"
        case .work: "briefcase.fill"
        case .jobSearch: "doc.text.magnifyingglass"
        case .educationTraining: "graduationcap.fill"
        case .bankingInsurance: "banknote.fill"
        case .childcareEducation: "figure.and.child.holdinghands"
        case .shopping: "basket.fill"
        case .health: "cross.case.fill"
        case .mediaUse: "newspaper.fill"
        case .mobility: "tram.fill"
        case .classroom: "person.3.fill"
        case .housing: "house.fill"
        }
    }
}

struct IntegrationLanguageSection: Identifiable, Hashable {
    let id: String
    let number: Int
    let level: CEFRLevel
    let band: String
    let title: String
    let subtitle: String
    let goal: String
    let lessonRange: ClosedRange<Int>
}

struct IntegrationLessonProfile: Hashable {
    let section: IntegrationLanguageSection
    let actionField: IntegrationActionField
    let context: String
    let canDoStatements: [String]
    let transferTask: String
    let speakingPrompt: String
    let writingPrompt: String
    let writingChecklist: [String]
    let textType: String
    let participationNote: String
    let isCheckpoint: Bool
}

struct OrientationCheck: Hashable {
    let question: String
    let choices: [String]
    let answer: String
    let explanation: String
}

struct OrientationLesson: Identifiable, Hashable {
    let id: String
    let order: Int
    let moduleID: String
    let title: String
    let goal: String
    let lessonUnits: Int
    let icon: String
    let keyPoints: [String]
    let situation: String
    let perspectives: [String]
    let actionTask: String
    let checks: [OrientationCheck]
}

struct OrientationCourseModule: Identifiable, Hashable {
    let id: String
    let number: Int?
    let title: String
    let subtitle: String
    let lessonUnits: Int
    let icon: String
}

enum GermanFederalState: String, CaseIterable, Codable, Identifiable {
    case badenWuerttemberg = "BW"
    case bavaria = "BY"
    case berlin = "BE"
    case brandenburg = "BB"
    case bremen = "HB"
    case hamburg = "HH"
    case hesse = "HE"
    case mecklenburgVorpommern = "MV"
    case lowerSaxony = "NI"
    case northRhineWestphalia = "NW"
    case rhinelandPalatinate = "RP"
    case saarland = "SL"
    case saxony = "SN"
    case saxonyAnhalt = "ST"
    case schleswigHolstein = "SH"
    case thuringia = "TH"

    static let storageKey = "selectedOrientationFederalState.v1"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .badenWuerttemberg: "Baden-Württemberg"
        case .bavaria: "Bayern"
        case .berlin: "Berlin"
        case .brandenburg: "Brandenburg"
        case .bremen: "Bremen"
        case .hamburg: "Hamburg"
        case .hesse: "Hessen"
        case .mecklenburgVorpommern: "Mecklenburg-Vorpommern"
        case .lowerSaxony: "Niedersachsen"
        case .northRhineWestphalia: "Nordrhein-Westfalen"
        case .rhinelandPalatinate: "Rheinland-Pfalz"
        case .saarland: "Saarland"
        case .saxony: "Sachsen"
        case .saxonyAnhalt: "Sachsen-Anhalt"
        case .schleswigHolstein: "Schleswig-Holstein"
        case .thuringia: "Thüringen"
        }
    }
}

enum OrientationQuestionScope: String, Codable {
    case general
    case state
}

struct OrientationQuestion: Identifiable, Hashable, Codable {
    static let requiredChoiceCount = 4

    let id: String
    let number: Int
    let scope: OrientationQuestionScope
    let stateCode: String?
    let question: String
    let choices: [String]
    let answerIndex: Int
    let imageName: String?

    var answer: String {
        guard choices.indices.contains(answerIndex) else { return "" }
        return choices[answerIndex]
    }

    var hasStandardChoiceFormat: Bool {
        choices.count == Self.requiredChoiceCount
            && choices.allSatisfy {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            && choices.indices.contains(answerIndex)
    }

    var usesNumberedImages: Bool {
        choices == ["Bild 1", "Bild 2", "Bild 3", "Bild 4"]
    }
}

struct OrientationQuestionCatalog: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let questions: [OrientationQuestion]
}

enum IntegrationCourseCurriculum {
    static let orientationCourseLanguageCode = "de"

    static let languageSections: [IntegrationLanguageSection] = [
        .init(
            id: "language-1",
            number: 1,
            level: .a1,
            band: "Basiskurs 1",
            title: "Arrive and connect",
            subtitle: "Identity, first contacts, and essential daily tasks",
            goal: "Use simple German to introduce yourself, ask for help, and complete first everyday interactions.",
            lessonRange: 1...13
        ),
        .init(
            id: "language-2",
            number: 2,
            level: .a1,
            band: "Basiskurs 2",
            title: "Manage everyday life",
            subtitle: "Mobility, health, work, learning, and public services",
            goal: "Handle familiar appointments, routes, purchases, and short conversations with growing independence.",
            lessonRange: 14...26
        ),
        .init(
            id: "language-3",
            number: 3,
            level: .a2,
            band: "Basiskurs 3",
            title: "Use local services",
            subtitle: "Housing, travel, health, work, and family services",
            goal: "Exchange connected information, explain routine problems, and confirm practical next steps.",
            lessonRange: 1...12
        ),
        .init(
            id: "language-4",
            number: 4,
            level: .a2,
            band: "Aufbausprachkurs 1",
            title: "Work and participate",
            subtitle: "Communication, public life, education, and administration",
            goal: "Take part in longer everyday exchanges and write clear messages for services, work, and community life.",
            lessonRange: 13...25
        ),
        .init(
            id: "language-5",
            number: 5,
            level: .b1,
            band: "Aufbausprachkurs 2",
            title: "Communicate independently",
            subtitle: "Work, education, media, society, and health",
            goal: "Explain experiences and problems clearly, support opinions, and cooperate on solutions.",
            lessonRange: 1...12
        ),
        .init(
            id: "language-6",
            number: 6,
            level: .b1,
            band: "Aufbausprachkurs 3",
            title: "B1 and DTZ readiness",
            subtitle: "Formal requests, conflict resolution, participation, and exam transfer",
            goal: "Communicate with enough structure and flexibility for independent daily life and B1-level assessment tasks.",
            lessonRange: 13...25
        )
    ]

    static let orientationModules: [OrientationCourseModule] = [
        .init(id: "orientation-start", number: nil, title: "Start", subtitle: "Erfahrungen, Fragen und Kursziele", lessonUnits: 3, icon: "flag.fill"),
        .init(id: "orientation-politics", number: 1, title: "Politik in der Demokratie", subtitle: "Rechte, Institutionen, Teilhabe und Verantwortung", lessonUnits: 35, icon: "building.columns.fill"),
        .init(id: "orientation-history", number: 2, title: "Geschichte und Verantwortung", subtitle: "Nationalsozialismus, Teilung, Wiedervereinigung und Europa", lessonUnits: 20, icon: "clock.arrow.circlepath"),
        .init(id: "orientation-society", number: 3, title: "Mensch und Gesellschaft", subtitle: "Gleichberechtigung, Vielfalt, Bildung, Arbeit und Zusammenleben", lessonUnits: 38, icon: "person.3.fill"),
        .init(id: "orientation-close", number: nil, title: "Abschluss", subtitle: "Anwendung, Teilhabe und Vorbereitung auf Leben in Deutschland", lessonUnits: 4, icon: "checkmark.seal.fill")
    ]

    static let orientationLessons: [OrientationLesson] = [
        orientationLesson(
            id: "orientation-01", order: 1, moduleID: "orientation-start", title: "Dein Leben in Deutschland", goal: "Verbinde deine eigenen Fragen und Erfahrungen mit den Themen des Orientierungskurses.", units: 3, icon: "map.fill",
            points: [
                "Integration umfasst Sprache, praktische Selbstständigkeit, gleichberechtigte Teilhabe und Wissen über Rechte und Pflichten.",
                "Menschen bringen unterschiedliche Erfahrungen in den Kurs mit. Verschiedene Sichtweisen respektvoll zu vergleichen gehört zum Lernen.",
                "Eine wichtige Frage lautet nicht nur: Was ist die Regel? Sondern auch: Wo finde ich verlässliche Hilfe und wie kann ich handeln?"
            ],
            situation: "Eine neue Nachbarin erhält von Freunden und in sozialen Medien unterschiedliche Hinweise zur Anmeldung ihres Wohnsitzes. Unterscheide Erfahrung, Meinung und offizielle Quelle.",
            perspectives: ["Was könnte diese Situation für eine neu zugewanderte Person belastend machen?", "Welche Behörde oder verlässliche Quelle kann den nächsten Schritt klären?"],
            action: "Erstelle eine persönliche Übersicht mit drei Orten, an denen du verlässliche Informationen vor Ort bekommst.",
            checks: [
                check("Was ist ein zentrales Ziel des Orientierungskurses?", ["Nur Fakten auswendig lernen", "Informierte Teilhabe ermöglichen", "Unterschiede nicht besprechen"], "Informierte Teilhabe ermöglichen", "Wissen wird nützlich, wenn es selbstständige Entscheidungen und gesellschaftliche Teilhabe unterstützt."),
                check("Was solltest du bei widersprüchlichen Hinweisen tun?", ["Der lautesten Meinung folgen", "Eine verlässliche Quelle prüfen", "Das Problem ignorieren"], "Eine verlässliche Quelle prüfen", "Offizielle oder fachlich verantwortliche Quellen helfen, Regeln und Abläufe zu überprüfen.")
            ]
        ),
        orientationLesson(
            id: "orientation-02", order: 2, moduleID: "orientation-politics", title: "Menschenwürde und Grundrechte", goal: "Verstehe, warum Grundrechte jeden Menschen schützen und staatliche Macht begrenzen.", units: 7, icon: "person.crop.circle.badge.checkmark",
            points: [
                "Die Würde des Menschen steht am Anfang des Grundgesetzes und darf nicht verletzt werden.",
                "Grundrechte schützen unter anderem persönliche Freiheit, Glauben, Meinungsäußerung, Gleichheit und Familienleben.",
                "Staatliche Stellen sind an diese Rechte gebunden. Grundrechte prägen auch ein respektvolles Zusammenleben."
            ],
            situation: "Eine Person wird in einer Behörde wegen ihrer Herkunft herabgewürdigt. Unterscheide unfreundliches Verhalten von möglicher Diskriminierung und bestimme sinnvolle nächste Schritte.",
            perspectives: ["Welches Recht oder welcher Grundsatz könnte betroffen sein?", "Wie kann die Person den Vorfall dokumentieren und sicher Beratung suchen?"],
            action: "Erkläre ein Grundrecht mit eigenen Worten und nenne ein Beispiel aus dem Alltag.",
            checks: [
                check("Welcher Grundsatz steht am Anfang des Grundgesetzes?", ["Die Menschenwürde", "Das Wirtschaftswachstum", "Der Wehrdienst"], "Die Menschenwürde", "Artikel 1 stellt die Menschenwürde in den Mittelpunkt der verfassungsmäßigen Ordnung."),
                check("Wer ist an die Grundrechte gebunden?", ["Nur private Vereine", "Die staatliche Gewalt", "Nur Besucherinnen und Besucher"], "Die staatliche Gewalt", "Gesetzgebung, Verwaltung und Rechtsprechung müssen die Grundrechte achten.")
            ]
        ),
        orientationLesson(
            id: "orientation-03", order: 3, moduleID: "orientation-politics", title: "Gleichberechtigung und Schutz vor Diskriminierung", goal: "Erkenne Grundsätze der Gleichbehandlung und praktische Reaktionen auf Diskriminierung.", units: 7, icon: "equal.circle.fill",
            points: [
                "Alle Menschen sind vor dem Gesetz gleich. Frauen und Männer sind gleichberechtigt.",
                "Benachteiligung wegen geschützter Merkmale kann im Arbeitsleben und beim Zugang zu vielen Gütern und Dienstleistungen rechtswidrig sein.",
                "Sinnvolle Schritte sind: Fakten notieren, Belege sichern, Beratung suchen und einen passenden Beschwerdeweg nutzen."
            ],
            situation: "Zwei gleich qualifizierte Bewerber werden unterschiedlich behandelt, nachdem ein Vermieter von der Religion einer Person erfährt. Besprich Belege, mögliche Erklärungen und Beratungsstellen.",
            perspectives: ["Welche Fakten sind bekannt und was sind Vermutungen?", "Wie würde ein faires Verfahren aussehen?"],
            action: "Dokumentiere einen diskriminierenden Vorfall sachlich in vier Sätzen, ohne Beleidigungen oder Spekulationen.",
            checks: [
                check("Was hilft bei der Meldung von Diskriminierung?", ["Eine sachliche Dokumentation", "Ein anonymes Gerücht", "Alle Nachrichten löschen"], "Eine sachliche Dokumentation", "Datum, Wortlaut, Unterlagen und Zeugen können einer Beratungsstelle helfen, den Vorfall einzuschätzen."),
                check("Für wen gilt die Gleichheit vor dem Gesetz?", ["Nur für Staatsangehörige", "Für alle Menschen", "Nur für berufstätige Erwachsene"], "Für alle Menschen", "Der verfassungsrechtliche Gleichheitsgrundsatz ist nicht auf eine gesellschaftliche Gruppe beschränkt.")
            ]
        ),
        orientationLesson(
            id: "orientation-04", order: 4, moduleID: "orientation-politics", title: "Demokratie, Rechtsstaat und Gewaltenteilung", goal: "Verstehe, wie Wahlen, Gesetzgebung, Verwaltung und unabhängige Gerichte zusammenwirken.", units: 7, icon: "scale.3d",
            points: [
                "Alle Staatsgewalt geht vom Volke aus und wird durch Wahlen, Abstimmungen und verfassungsmäßige Organe ausgeübt.",
                "Gesetzgebung, vollziehende Gewalt und Rechtsprechung begrenzen und kontrollieren einander.",
                "Staatliches Handeln braucht eine Rechtsgrundlage und kann mit rechtmäßigen Verfahren überprüft werden."
            ],
            situation: "Ein Einwohner ist mit einer Verwaltungsentscheidung nicht einverstanden. Vergleiche Beschwerde, Widerspruch, Klage und einen Beitrag in sozialen Medien als verschiedene Reaktionen.",
            perspectives: ["Welche Stelle hat die Entscheidung getroffen?", "Welches Verfahren kann sie prüfen und welche Frist könnte wichtig sein?"],
            action: "Zeichne ein einfaches Schaubild mit Parlament, Regierung oder Verwaltung und Gerichten. Notiere für jede Stelle eine Aufgabe.",
            checks: [
                check("Warum wird staatliche Macht geteilt?", ["Um unkontrollierte Macht zu verhindern", "Um Gerichte abzuschaffen", "Um Wahlen abzusagen"], "Um unkontrollierte Macht zu verhindern", "Getrennte Institutionen können staatliche Macht begrenzen, überprüfen und ausgleichen."),
                check("Was ist eine rechtsstaatliche Reaktion auf eine umstrittene Entscheidung?", ["Das vorgesehene Rechtsverfahren nutzen", "Eine Mitarbeiterin bedrohen", "Alle Fristen ignorieren"], "Das vorgesehene Rechtsverfahren nutzen", "Widerspruchsverfahren und Gerichte ermöglichen eine geordnete Prüfung, wenn die Voraussetzungen erfüllt sind.")
            ]
        ),
        orientationLesson(
            id: "orientation-05", order: 5, moduleID: "orientation-politics", title: "Föderalismus und staatliche Institutionen", goal: "Erkenne, welche staatliche Ebene für häufige Alltagsfragen zuständig ist.", units: 7, icon: "square.3.layers.3d",
            points: [
                "Deutschland ist ein Bundesstaat. Bund, Länder und Kommunen teilen sich die staatlichen Aufgaben.",
                "Schulen und Polizei werden stark von den Ländern geprägt. Kommunen übernehmen viele Aufgaben vor Ort.",
                "Wer die zuständige Ebene kennt, spart Zeit bei der Informationssuche und bei Anträgen."
            ],
            situation: "Eine Familie hat Fragen zur Schulanmeldung, zu Aufenthaltsdokumenten, zur Müllabfuhr und zu Bundessteuern. Ordne die Fragen den wahrscheinlich zuständigen Stellen zu.",
            perspectives: ["Welche Frage ist kommunal und welche könnte den Bund betreffen?", "Wie kann eine offizielle Website die Zuständigkeit bestätigen?"],
            action: "Finde die offizielle Website deiner Kommune und suche drei Dienstleistungen, die du benötigen könntest.",
            checks: [
                check("Wer informiert normalerweise über die örtliche Müllabfuhr?", ["Die Kommune", "Das Europäische Parlament", "Eine ausländische Botschaft"], "Die Kommune", "Viele unmittelbare Dienstleistungen werden von Städten, Landkreisen oder Gemeinden organisiert."),
                check("Warum ist Föderalismus im Alltag wichtig?", ["Die Zuständigkeiten unterscheiden sich je nach Ebene", "Alle Behörden erledigen dieselbe Arbeit", "Gesetze unterscheiden sich nie"], "Die Zuständigkeiten unterscheiden sich je nach Ebene", "Die richtige Anlaufstelle hängt davon ab, ob der Bund, ein Land oder die Kommune zuständig ist.")
            ]
        ),
        orientationLesson(
            id: "orientation-06", order: 6, moduleID: "orientation-politics", title: "Wahlen, Parteien und politische Teilhabe", goal: "Verstehe repräsentative Wahlen und Möglichkeiten der Beteiligung über das Wählen hinaus.", units: 7, icon: "checkmark.square.fill",
            points: [
                "Demokratische Wahlen sind allgemein, unmittelbar, frei, gleich und geheim.",
                "Parteien treten mit unterschiedlichen Programmen an und wirken an der politischen Willensbildung mit.",
                "Zur Teilhabe gehören auch Petitionen, Vereine, Demonstrationen, Bürgerversammlungen und der Kontakt zu Abgeordneten."
            ],
            situation: "Eine örtliche Buslinie soll möglicherweise eingestellt werden. Die Anwohner sind uneinig, ob sie den Gemeinderat kontaktieren, eine Petition starten, demonstrieren oder nichts tun sollen.",
            perspectives: ["Welche Wege sind rechtmäßig und erreichen wahrscheinlich die Verantwortlichen?", "Wie können Menschen mit unterschiedlichen Ansichten einbezogen werden?"],
            action: "Vergleiche zwei rechtmäßige Formen der Beteiligung und wähle eine für ein örtliches Anliegen aus.",
            checks: [
                check("Wie wird die Stimme bei einer demokratischen Wahl abgegeben?", ["Geheim", "Öffentlich unterschrieben", "Vom Arbeitgeber bestimmt"], "Geheim", "Das Wahlgeheimnis schützt die freie Wahlentscheidung."),
                check("Was ist eine Form politischer Teilhabe?", ["Eine rechtmäßige Petition", "Die Bedrohung politischer Gegner", "Die Zerstörung von Stimmzetteln"], "Eine rechtmäßige Petition", "Mit Petitionen können Menschen Bitten oder Beschwerden an zuständige Stellen richten.")
            ]
        ),
        orientationLesson(
            id: "orientation-07", order: 7, moduleID: "orientation-history", title: "Nationalsozialismus und Holocaust", goal: "Verstehe, warum Erinnerung und Verantwortung für die deutsche Demokratie zentral sind.", units: 5, icon: "candle.fill",
            points: [
                "Die nationalsozialistische Diktatur zerstörte die Demokratie, verfolgte Gegner und beging systematischen Massenmord.",
                "Sechs Millionen europäische Jüdinnen und Juden wurden im Holocaust ermordet. Auch viele andere Gruppen wurden verfolgt und getötet.",
                "Die Erinnerung an diese Verbrechen stärkt den Einsatz für Menschenwürde, Minderheitenschutz und gegen Antisemitismus und Rassismus."
            ],
            situation: "Beim Besuch einer Gedenkstätte entstehen schwierige Fragen zur Verantwortung für Ereignisse vor der eigenen Geburt. Besprich den Unterschied zwischen persönlicher Schuld und heutiger Verantwortung.",
            perspectives: ["Warum bewahren Demokratien Beweise und Erinnerungen?", "Wie kann Erinnerung das heutige Handeln beeinflussen?"],
            action: "Besuche oder recherchiere eine Gedenkstätte in deiner Nähe und fasse zusammen, wessen Geschichte dort bewahrt wird.",
            checks: [
                check("Welches politische System herrschte von 1933 bis 1945 in Deutschland?", ["Eine Diktatur", "Eine stabile Demokratie", "Ein Stadtrat"], "Eine Diktatur", "Der Nationalsozialismus beseitigte demokratische Institutionen und errichtete eine gewaltsame Diktatur."),
                check("Warum ist Erinnerung heute wichtig?", ["Sie stärkt den Schutz von Würde und Demokratie", "Sie ersetzt die gesamte heutige Politik", "Sie beseitigt individuelle Rechte"], "Sie stärkt den Schutz von Würde und Demokratie", "Historisches Verständnis hilft, Menschenverachtung und autoritäre Entwicklungen zu erkennen und ihnen zu widerstehen.")
            ]
        ),
        orientationLesson(
            id: "orientation-08", order: 8, moduleID: "orientation-history", title: "Zwei deutsche Staaten und Wiedervereinigung", goal: "Verstehe Teilung, SED-Diktatur, friedlichen Protest und Wiedervereinigung.", units: 5, icon: "arrow.left.and.right.circle.fill",
            points: [
                "Nach dem Zweiten Weltkrieg wurde Deutschland geteilt. 1949 entstanden zwei deutsche Staaten.",
                "Die Bundesrepublik entwickelte sich als parlamentarische Demokratie. Die DDR war eine sozialistische Diktatur ohne freie gesamtstaatliche Wahlen.",
                "Friedliche Proteste trugen 1989 zum Fall der Berliner Mauer bei. 1990 folgte die deutsche Einheit."
            ],
            situation: "Zwei Familienbiografien beschreiben das Leben in Ost- und Westdeutschland sehr unterschiedlich. Nimm persönliche Erinnerungen ernst und überprüfe zugleich den größeren historischen Zusammenhang.",
            perspectives: ["Was kann eine persönliche Erinnerung gut erklären?", "Wofür braucht man Dokumente oder mehrere Quellen?"],
            action: "Erstelle eine Zeitleiste mit 1949, 1961, 1989 und 1990 und erkläre jedes Jahr in einem Satz.",
            checks: [
                check("Was geschah 1989?", ["Die Berliner Mauer fiel", "Die zwei deutschen Staaten wurden gegründet", "Das Grundgesetz endete"], "Die Berliner Mauer fiel", "Die Öffnung der Mauer folgte auf Massenproteste und politische Veränderungen in der DDR."),
                check("Wann fand die deutsche Wiedervereinigung statt?", ["1990", "1949", "1961"], "1990", "Am 3. Oktober 1990 trat die Deutsche Demokratische Republik der Bundesrepublik Deutschland bei.")
            ]
        ),
        orientationLesson(
            id: "orientation-09", order: 9, moduleID: "orientation-history", title: "Deutschland in Europa", goal: "Verbinde Deutschlands Entwicklung nach dem Krieg mit europäischer Zusammenarbeit und gemeinsamen Institutionen.", units: 5, icon: "globe.europe.africa.fill",
            points: [
                "Die europäische Zusammenarbeit entstand auch aus dem Ziel, nach zerstörerischen Kriegen den Frieden zu sichern.",
                "Die Europäische Union koordiniert Bereiche wie Binnenmarkt, gemeinsame Regeln und Zusammenarbeit der Mitgliedstaaten.",
                "Entscheidungen auf europäischer, Bundes-, Landes- und kommunaler Ebene können den Alltag beeinflussen."
            ],
            situation: "Eine Arbeitnehmerin zieht zwischen zwei EU-Staaten um und hat Fragen zu Berufsabschlüssen, Aufenthalt, Beschäftigung und Wahlrechten.",
            perspectives: ["Welche Frage könnte auf EU-Ebene geregelt sein?", "Welche Frage braucht weiterhin eine nationale oder kommunale Anlaufstelle?"],
            action: "Wähle einen EU-Politikbereich aus dem Alltag und erkläre einen Vorteil sowie eine dazugehörige Debatte.",
            checks: [
                check("Warum wurde die europäische Zusammenarbeit nach dem Krieg vertieft?", ["Um Frieden und Zusammenarbeit zu fördern", "Um alle nationalen Institutionen abzuschaffen", "Um Wahlen zu beenden"], "Um Frieden und Zusammenarbeit zu fördern", "Wirtschaftliche und politische Zusammenarbeit sollte neue Konflikte unwahrscheinlicher machen."),
                check("Kommen alle Entscheidungen in Deutschland von der EU?", ["Nein", "Ja", "Nur kommunale Entscheidungen"], "Nein", "Zuständigkeiten sind auf die europäische, Bundes-, Landes- und kommunale Ebene verteilt.")
            ]
        ),
        orientationLesson(
            id: "orientation-10", order: 10, moduleID: "orientation-history", title: "Migration, Erinnerung und Zugehörigkeit", goal: "Ordne unterschiedliche Migrationsgeschichten in die neuere deutsche Geschichte ein.", units: 5, icon: "person.2.wave.2.fill",
            points: [
                "Flucht, Vertreibung, Arbeitsmigration, Familiennachzug, EU-Freizügigkeit und Schutzsuche haben Deutschland geprägt.",
                "Zugehörigkeit kann Rechtsstatus, Teilhabe, Sprache, Beziehungen und persönliche Identität umfassen.",
                "Eine demokratische Erinnerungskultur kann verschiedene Biografien verbinden, ohne eine Geschichte zur einzig gültigen zu machen."
            ],
            situation: "Eine öffentliche Ausstellung bezeichnet eine Gruppe als neu Zugewanderte, obwohl manche Familien seit Generationen in Deutschland leben. Besprich Sprache, Identität und Einbeziehung.",
            perspectives: ["Wer darf Zugehörigkeit definieren?", "Wie kann eine Ausstellung unterschiedliche Biografien fair darstellen?"],
            action: "Erstelle mit respektvoller Sprache eine kurze Migrationszeitleiste für eine Familie, ein Viertel oder einen Arbeitsplatz.",
            checks: [
                check("Gab es in der deutschen Geschichte nur eine Form von Migration?", ["Nein", "Ja", "Nur Arbeitsmigration zählt"], "Nein", "Migration umfasst viele Gründe, rechtliche Situationen und historische Zeiträume."),
                check("Was stärkt Zugehörigkeit in einer Demokratie?", ["Teilhabe und gleiche Rechte", "Eine bestimmte Familienherkunft", "Schweigen über Unterschiede"], "Teilhabe und gleiche Rechte", "Zugehörigkeit wird gestärkt, wenn Menschen teilhaben können und mit gleicher Würde behandelt werden.")
            ]
        ),
        orientationLesson(
            id: "orientation-11", order: 11, moduleID: "orientation-society", title: "Familie, Gleichberechtigung und Selbstbestimmung", goal: "Wende Gleichberechtigung und Selbstbestimmung auf Entscheidungen in Familie und Partnerschaft an.", units: 8, icon: "figure.2.and.child.holdinghands",
            points: [
                "Erwachsene entscheiden selbst, ob und wen sie heiraten. Zwangsheirat und Gewalt sind nicht akzeptabel.",
                "Frauen und Männer haben gleiche Rechte in Bildung, Arbeit, Eigentum, Familienentscheidungen und öffentlichem Leben.",
                "Kinder haben Rechte auf Schutz und Entwicklung. Öffentliche Stellen können Familien in schwierigen Situationen unterstützen."
            ],
            situation: "Ein Paar ist uneinig, ob eine Person arbeiten oder einen Kurs besuchen darf. Untersuche rechtliche Gleichberechtigung, praktische Kinderbetreuung und respektvolle Entscheidungen.",
            perspectives: ["Welche Entscheidung liegt bei der einzelnen Person?", "Welche praktische Unterstützung könnte den Konflikt verringern?"],
            action: "Finde eine örtliche Beratungsstelle oder Familienhilfe und notiere, wie du sie erreichst.",
            checks: [
                check("Wer entscheidet, ob eine erwachsene Person eine Arbeit aufnimmt?", ["Die erwachsene Person selbst", "Eine Nachbarin", "Eine Sprachlehrkraft"], "Die erwachsene Person selbst", "Erwachsene besitzen im Rahmen der Gesetze persönliche Freiheit und gleiche Rechte."),
                check("Was kann einer belasteten Familie helfen?", ["Eine passende Beratungsstelle", "Gewalt verheimlichen", "Alle Wahlmöglichkeiten entziehen"], "Eine passende Beratungsstelle", "Fachstellen können vertrauliche Informationen, Schutz und praktische Unterstützung anbieten.")
            ]
        ),
        orientationLesson(
            id: "orientation-12", order: 12, moduleID: "orientation-society", title: "Bildung, Arbeit und Chancen", goal: "Verstehe Bildungswege, Rechte am Arbeitsplatz und Möglichkeiten zur Weiterqualifizierung.", units: 8, icon: "graduationcap.fill",
            points: [
                "Bildung wird hauptsächlich von den Ländern organisiert. Deshalb können Schulsysteme und Verfahren unterschiedlich sein.",
                "Die duale Berufsausbildung verbindet in vielen Berufen das Lernen im Betrieb mit der Berufsschule.",
                "Arbeitsverhältnisse bringen Rechte und Pflichten mit sich. Verträge, Arbeitszeit, Lohnabrechnungen und Arbeitsschutz sind wichtig."
            ],
            situation: "Eine erwachsene Person besitzt Berufserfahrung aus dem Ausland, aber keinen in Deutschland anerkannten Abschluss. Vergleiche Anerkennung, Weiterbildung, Berufsausbildung und Berufsberatung.",
            perspectives: ["Welche bisherigen Kenntnisse sollten dokumentiert werden?", "Welche Stelle kann qualifiziert beraten?"],
            action: "Erstelle eine Checkliste für das nächste Bildungs- oder Berufsziel und nenne eine offizielle Beratungsquelle.",
            checks: [
                check("Wer trägt die Hauptverantwortung für die Schulbildung?", ["Die Länder", "Nur die EU", "Private Arbeitgeber"], "Die Länder", "Bildungspolitik ist eine zentrale Aufgabe der deutschen Bundesländer."),
                check("Was gehört meist zur dualen Berufsausbildung?", ["Betrieb und Berufsschule", "Nur eine Universität", "Kein praktisches Lernen"], "Betrieb und Berufsschule", "Die duale Ausbildung verbindet betriebliche Praxis mit Unterricht in der Berufsschule.")
            ]
        ),
        orientationLesson(
            id: "orientation-13", order: 13, moduleID: "orientation-society", title: "Religion, Vielfalt und Toleranz", goal: "Unterscheide Freiheit, respektvolle Meinungsverschiedenheit und Grenzen zum Schutz anderer.", units: 8, icon: "person.3.sequence.fill",
            points: [
                "Glaubensfreiheit umfasst, eine Religion zu haben, sie zu wechseln, sie auszuüben oder keiner Religion anzugehören.",
                "Meinungsfreiheit schützt auch deutlichen Widerspruch. Sie hebt aber Gesetze zum Schutz von Würde, Sicherheit und anderen Rechten nicht auf.",
                "Toleranz verlangt keine Zustimmung. Sie verlangt friedliches Zusammenleben und gleichen Respekt vor dem Gesetz."
            ],
            situation: "Nachbarn streiten über eine religiöse Feier, Lärm und Regeln im gemeinsamen Haus. Unterscheide Glauben, Ausdruck, konkrete Störung und einen tragfähigen Kompromiss.",
            perspectives: ["Welche Freiheiten sind für die beteiligten Personen wichtig?", "Welche neutrale Regel könnte für alle gleichermaßen gelten?"],
            action: "Übe vier Schritte zur Konfliktlösung: beschreiben, zuhören, ein Bedürfnis nennen und einen fairen nächsten Schritt vorschlagen.",
            checks: [
                check("Umfasst Glaubensfreiheit auch, keiner Religion anzugehören?", ["Ja", "Nein", "Nur mit Genehmigung"], "Ja", "Die Religionsfreiheit schützt religiöse und nicht religiöse Überzeugungen."),
                check("Was verlangt Toleranz?", ["Friedliches und gleichberechtigtes Zusammenleben", "Zustimmung zu jedem Glauben", "Das Verschweigen aller Unterschiede"], "Friedliches und gleichberechtigtes Zusammenleben", "Menschen dürfen unterschiedlicher Meinung sein und zugleich gleiche Rechte sowie rechtmäßige Grenzen achten.")
            ]
        ),
        orientationLesson(
            id: "orientation-14", order: 14, moduleID: "orientation-society", title: "Soziale Sicherung und Solidarität", goal: "Verstehe die Grundidee gemeinsamer sozialer Absicherung und persönlicher Verantwortung.", units: 7, icon: "person.2.badge.gearshape.fill",
            points: [
                "Die Sozialversicherung hilft bei großen Lebensrisiken wie Krankheit, Arbeitslosigkeit, Pflegebedürftigkeit, Arbeitsunfällen und Alter.",
                "Beiträge, Steuern, Anspruchsregeln und persönliche Pflichten verbinden die eigene Situation mit gemeinsamer Unterstützung.",
                "Verlässliche Beratung ist wichtig, weil Leistungen und Versicherungsfragen von konkreten Fakten abhängen."
            ],
            situation: "Ein Arbeitnehmer wird krank, erhält mehrere Schreiben und weiß nicht, ob er Arbeitgeber, Krankenkasse, Arztpraxis oder Jobcenter kontaktieren soll.",
            perspectives: ["Welches Dokument zeigt Absender und Frist?", "Welche Fachstelle kann den konkreten Fall erklären?"],
            action: "Entwickle eine Routine für Schreiben: öffnen, Absender erkennen, Frist markieren, Schlüsselbegriffe klären und die zuständige Stelle fragen.",
            checks: [
                check("Warum sollten behördliche Schreiben schnell geöffnet werden?", ["Sie können Fristen enthalten", "Sie sind nie wichtig", "Nur die Farbe zählt"], "Sie können Fristen enthalten", "Eine versäumte Antworts- oder Widerspruchsfrist kann die Handlungsmöglichkeiten einschränken."),
                check("Warum ist Beratung zum Einzelfall sinnvoll?", ["Regeln hängen von persönlichen Fakten ab", "Jede Person erhält dieselbe Leistung", "Unterlagen sind unnötig"], "Regeln hängen von persönlichen Fakten ab", "Anspruch und Zuständigkeit hängen oft von Arbeit, Aufenthalt, Versicherung und Familiensituation ab.")
            ]
        ),
        orientationLesson(
            id: "orientation-15", order: 15, moduleID: "orientation-society", title: "Medien, öffentliche Debatte und digitale Sicherheit", goal: "Bewerte Informationen und beteilige dich verantwortungsvoll am digitalen öffentlichen Leben.", units: 7, icon: "newspaper.fill",
            points: [
                "Eine freie Presse kann Macht untersuchen und verschiedene Perspektiven zeigen. Medien treffen dennoch redaktionelle Entscheidungen.",
                "Eine verlässliche Prüfung beachtet Quelle, Datum, Belege, Zusammenhang und Bestätigung durch unabhängige Quellen.",
                "Digitale Teilhabe verlangt außerdem Datenschutzbewusstsein, respektvolles Verhalten und das Erkennen von Manipulation oder Betrug."
            ],
            situation: "Eine häufig geteilte Nachricht behauptet ohne Quellenangabe, morgen trete ein neues Gesetz in Kraft. Entscheide, was du vor dem Weiterleiten prüfen musst.",
            perspectives: ["Wer hat die Behauptung veröffentlicht und welche Belege sind verlinkt?", "Könnten Bild oder Überschrift alt, bearbeitet oder ohne Zusammenhang sein?"],
            action: "Prüfe eine aktuelle Behauptung mit fünf Quellenkriterien, bevor du sie teilst.",
            checks: [
                check("Was ist ein sinnvoller erster Quellencheck?", ["Den Herausgeber feststellen", "Die Emojis zählen", "Sofort weiterleiten"], "Den Herausgeber feststellen", "Urheberschaft und Verantwortlichkeit helfen, die Verlässlichkeit einzuschätzen."),
                check("Wird ein beliebter Beitrag automatisch wahr?", ["Nein", "Ja", "Nur wenn er kurz ist"], "Nein", "Beliebtheit ist kein Beleg. Behauptungen brauchen weiterhin Quellen und Zusammenhang.")
            ]
        ),
        orientationLesson(
            id: "orientation-16", order: 16, moduleID: "orientation-close", title: "Sicher teilhaben", goal: "Verbinde Wissen, Quellenprüfung, respektvollen Dialog und praktisches Handeln.", units: 4, icon: "checkmark.seal.fill",
            points: [
                "Orientierungswissen ist besonders nützlich, wenn du es auf eine unbekannte Situation anwenden kannst.",
                "Eine gute Reaktion benennt das Problem, das passende Recht oder die Verantwortung, eine verlässliche Quelle und den praktischen nächsten Schritt.",
                "Teilhabe kann vor Ort mit informierten Gesprächen, Vereinen, Ehrenamt, Petitionen, Wahlen und öffentlichen Angeboten beginnen."
            ],
            situation: "In deinem Viertel tritt ein Problem immer wieder auf und betrifft mehrere Gruppen unterschiedlich. Entwickle eine Reaktion, die Fakten sammelt, Perspektiven einbezieht und die zuständige Stelle erreicht.",
            perspectives: ["Wessen Stimmen fehlen in der Diskussion?", "Welche Belege und welcher rechtmäßige Beteiligungsweg können das Anliegen voranbringen?"],
            action: "Erstelle einen persönlichen Teilhabeplan mit einem Anliegen, einer Quelle, einer Anlaufstelle und einer realistischen ersten Handlung.",
            checks: [
                check("Was macht Orientierungswissen praktisch?", ["Es auf Entscheidungen anwenden", "Fakten ohne Zusammenhang wiederholen", "Jedes öffentliche Anliegen vermeiden"], "Es auf Entscheidungen anwenden", "Für die Anwendung muss Wissen mit Rechten, Pflichten, Quellen und Handlungen verbunden werden."),
                check("Was ist ein konstruktiver erster Schritt bei einem örtlichen Anliegen?", ["Fakten sammeln und die zuständige Stelle kontaktieren", "Eine ungeprüfte Anschuldigung verbreiten", "Andersdenkende bedrohen"], "Fakten sammeln und die zuständige Stelle kontaktieren", "Belege und ein rechtmäßiger Weg bilden die Grundlage für konstruktive Teilhabe.")
            ]
        )
    ]

    static func orientationQuestionCatalogs(
        for state: GermanFederalState
    ) -> [OrientationQuestionCatalog] {
        let general = OrientationQuestionRepository.generalQuestions
        let ranges = [0..<100, 100..<200, 200..<300]
        var catalogs = ranges.enumerated().map { index, range in
            OrientationQuestionCatalog(
                id: "general-\(index + 1)",
                title: "Allgemeine Fragen \(range.lowerBound + 1)-\(range.upperBound)",
                subtitle: "Bundesweiter BAMF-Fragenkatalog",
                icon: ["building.columns.fill", "clock.arrow.circlepath", "person.3.fill"][index],
                questions: range.compactMap { general.indices.contains($0) ? general[$0] : nil }
            )
        }
        catalogs.append(
            OrientationQuestionCatalog(
                id: "state-\(state.rawValue.lowercased())",
                title: state.name,
                subtitle: "10 landesbezogene BAMF-Fragen",
                icon: "map.fill",
                questions: OrientationQuestionRepository.questions(for: state)
            )
        )
        return catalogs
    }

    static func orientationQuestions(for state: GermanFederalState) -> [OrientationQuestion] {
        orientationQuestionCatalogs(for: state).flatMap(\.questions)
    }

    static func orientationQuestion(
        number: Int,
        scope: OrientationQuestionScope,
        for state: GermanFederalState
    ) -> OrientationQuestion? {
        let questions: [OrientationQuestion]
        switch scope {
        case .general:
            questions = OrientationQuestionRepository.generalQuestions
        case .state:
            questions = OrientationQuestionRepository.questions(for: state)
        }
        return questions.first { $0.number == number }
    }

    static var allOrientationQuestions: [OrientationQuestion] {
        OrientationQuestionRepository.allQuestions
    }

    static func languageSection(for level: CEFRLevel, lessonOrder: Int) -> IntegrationLanguageSection {
        languageSections.first {
            $0.level == level && $0.lessonRange.contains(lessonOrder)
        } ?? languageSections.first { $0.level == level }!
    }

    static func languageCourseModules(level: CEFRLevel) -> [CurriculumModuleDescriptor] {
        let sequence = CurriculumProgression.grammarSequences[level] ?? []
        return languageSections.filter { $0.level == level }.map { section in
            let ids = sequence.enumerated().compactMap { index, id in
                section.lessonRange.contains(index + 1) ? id : nil
            }
            return CurriculumModuleDescriptor(
                id: section.id,
                number: section.number,
                title: section.title,
                subtitle: "\(section.band) · \(section.subtitle)",
                icon: sectionIcon(section.number),
                itemIDs: ids
            )
        }
    }

    static func profile(
        level: CEFRLevel,
        order: Int,
        grammarTitle: String,
        vocabularyThemes: [String] = []
    ) -> IntegrationLessonProfile {
        let section = languageSection(for: level, lessonOrder: order)
        let sequence = actionFieldSequence[level] ?? [.socialContacts]
        let field = sequence[min(max(order - 1, 0), sequence.count - 1)]
        let primary = primaryCanDo(field: field, level: level)
        let task = transferTask(field: field, level: level)
        let textType = textType(field: field, level: level)
        let theme = vocabularyThemes.first
        let context = contextDescription(field: field, level: level, theme: theme)
        return IntegrationLessonProfile(
            section: section,
            actionField: field,
            context: context,
            canDoStatements: [
                primary,
                "I can use \(grammarTitle.lowercased()) to make my meaning clear in this situation.",
                repairCanDo(field: field, level: level)
            ],
            transferTask: task,
            speakingPrompt: "Role-play a \(field.title.lowercased()) situation: \(task) Speak in complete turns, react to the other person, and confirm the next step.",
            writingPrompt: "Write a \(textType) for this situation: \(task)",
            writingChecklist: [
                "I included every requested fact and a clear next step.",
                "I used the conventions of a \(textType).",
                "I used \(grammarTitle.lowercased()) at least twice.",
                "I checked verb position, noun capitalization, and polite forms.",
                "The reader can understand what should happen next."
            ],
            textType: textType,
            participationNote: participationNote(field: field),
            isCheckpoint: order == 12 || order == 25
        )
    }

    static func profile(for lesson: CompleteLessonDTO, vocabularyThemes: [String] = []) -> IntegrationLessonProfile {
        profile(
            level: lesson.level,
            order: lesson.order,
            grammarTitle: lesson.title,
            vocabularyThemes: vocabularyThemes
        )
    }

    private static let actionFieldSequence: [CEFRLevel: [IntegrationActionField]] = [
        .a1: [
            .migrationAndIdentity, .socialContacts, .childcareEducation, .socialContacts, .classroom,
            .bankingInsurance, .housing, .housing, .shopping, .shopping, .bankingInsurance, .mobility,
            .mobility, .migrationAndIdentity, .health, .work, .jobSearch, .educationTraining,
            .feelingsOpinions, .socialContacts, .conflictResolution, .mobility, .mediaUse, .languageLearning, .authorities
        ],
        .a2: [
            .socialContacts, .migrationAndIdentity, .languageLearning, .housing, .bankingInsurance,
            .socialContacts, .feelingsOpinions, .mobility, .mediaUse, .health, .childcareEducation, .work,
            .jobSearch, .mediaUse, .authorities, .feelingsOpinions, .conflictResolution, .classroom,
            .conflictResolution, .feelingsOpinions, .work, .authorities, .educationTraining, .bankingInsurance, .authorities
        ],
        .b1: [
            .socialContacts, .migrationAndIdentity, .mediaUse, .conflictResolution, .feelingsOpinions,
            .socialContacts, .work, .jobSearch, .educationTraining, .mediaUse, .work, .feelingsOpinions,
            .childcareEducation, .health, .bankingInsurance, .feelingsOpinions, .conflictResolution,
            .conflictResolution, .classroom, .mediaUse, .feelingsOpinions, .conflictResolution,
            .authorities, .migrationAndIdentity, .languageLearning
        ]
    ]

    private static func sectionIcon(_ number: Int) -> String {
        switch number {
        case 1: "person.2.fill"
        case 2: "basket.fill"
        case 3: "building.2.fill"
        case 4: "briefcase.fill"
        case 5: "bubble.left.and.bubble.right.fill"
        default: "checkmark.seal.fill"
        }
    }

    private static func primaryCanDo(field: IntegrationActionField, level: CEFRLevel) -> String {
        switch (field, level) {
        case (.migrationAndIdentity, .a1): "I can give basic personal information and ask another person simple questions."
        case (.migrationAndIdentity, .a2): "I can explain my background, current situation, and an immediate practical need."
        case (.migrationAndIdentity, .b1): "I can describe a migration or integration experience and explain what support or change is needed."
        case (.feelingsOpinions, .a1): "I can say how I feel and give a simple preference."
        case (.feelingsOpinions, .a2): "I can explain a feeling or opinion with a reason and react politely."
        case (.feelingsOpinions, .b1): "I can present and support a position while acknowledging another perspective."
        case (.conflictResolution, .a1): "I can say that something is wrong and ask for simple help."
        case (.conflictResolution, .a2): "I can describe a problem, listen to a response, and agree on a practical solution."
        case (.conflictResolution, .b1): "I can address disagreement objectively, justify my request, and negotiate a clear next step."
        case (.socialContacts, .a1): "I can greet people, exchange personal information, and make a simple arrangement."
        case (.socialContacts, .a2): "I can maintain a social conversation, ask follow-up questions, and respond naturally."
        case (.socialContacts, .b1): "I can build and maintain social contact across different viewpoints and levels of formality."
        case (.languageLearning, .a1): "I can ask what a word means and request repetition or slower speech."
        case (.languageLearning, .a2): "I can explain a learning difficulty and choose a useful practice strategy."
        case (.languageLearning, .b1): "I can evaluate my language performance and plan targeted improvement for a B1 task."
        case (.authorities, .a1): "I can state my request, show a document, and ask what to do next."
        case (.authorities, .a2): "I can explain an administrative request and confirm documents, deadlines, and next steps."
        case (.authorities, .b1): "I can handle a formal administrative exchange, clarify a decision, and make a reasoned request."
        case (.work, .a1): "I can understand and exchange basic information about tasks, times, and availability."
        case (.work, .a2): "I can explain a routine workplace problem and coordinate a practical solution."
        case (.work, .b1): "I can contribute to workplace communication, explain a problem, and agree on responsibilities."
        case (.jobSearch, .a1): "I can say what work I do or want and ask about a simple job requirement."
        case (.jobSearch, .a2): "I can describe experience and availability and ask informed questions about a vacancy."
        case (.jobSearch, .b1): "I can present my qualifications with examples and handle common interview follow-up questions."
        case (.educationTraining, .a1): "I can ask about a course, timetable, or simple registration requirement."
        case (.educationTraining, .a2): "I can compare education options and ask about entry requirements and recognition."
        case (.educationTraining, .b1): "I can explain an education goal, compare routes, and request qualified guidance."
        case (.bankingInsurance, .a1): "I can ask about a payment, price, account, or appointment using basic information."
        case (.bankingInsurance, .a2): "I can clarify a payment or insurance issue and ask which documents are required."
        case (.bankingInsurance, .b1): "I can describe a financial or insurance problem precisely and compare proposed solutions."
        case (.childcareEducation, .a1): "I can give basic information about a child and ask about times, food, or materials."
        case (.childcareEducation, .a2): "I can discuss a child's routine, learning, or support need and confirm an arrangement."
        case (.childcareEducation, .b1): "I can take part in a parent-school conversation and agree on concrete support steps."
        case (.shopping, .a1): "I can ask for an item, understand the price, and complete a simple purchase."
        case (.shopping, .a2): "I can compare products, explain a problem, and request an exchange or service."
        case (.shopping, .b1): "I can make a clear consumer complaint and negotiate a reasonable remedy."
        case (.health, .a1): "I can name a symptom, arrange an appointment, and understand a simple instruction."
        case (.health, .a2): "I can describe symptoms and duration, answer follow-up questions, and confirm medical advice."
        case (.health, .b1): "I can give a structured health history, clarify risks, and discuss a treatment or prevention plan."
        case (.mediaUse, .a1): "I can understand basic information in a message, sign, app, or timetable."
        case (.mediaUse, .a2): "I can identify the purpose and key details of everyday media and respond appropriately."
        case (.mediaUse, .b1): "I can compare sources, summarize a claim, and explain why information appears reliable or doubtful."
        case (.mobility, .a1): "I can ask for a route, understand simple travel information, and buy the correct ticket."
        case (.mobility, .a2): "I can explain a delay or route problem and arrange an alternative connection."
        case (.mobility, .b1): "I can handle a complex travel disruption and communicate its consequences and preferred solution."
        case (.classroom, .a1): "I can follow a simple instruction and ask for clarification in class."
        case (.classroom, .a2): "I can take part in pair work, compare answers, and explain what I do not understand."
        case (.classroom, .b1): "I can collaborate on a learning task, give useful feedback, and reflect on a strategy."
        case (.housing, .a1): "I can describe my home, ask about basic costs, and report a simple problem."
        case (.housing, .a2): "I can ask detailed housing questions and arrange action on a repair or contract issue."
        case (.housing, .b1): "I can document a housing problem, refer to an agreement, and negotiate a deadline for action."
        }
    }

    private static func contextDescription(field: IntegrationActionField, level: CEFRLevel, theme: String?) -> String {
        let base: String
        switch field {
        case .migrationAndIdentity: base = "a registration, neighborhood, or personal-background conversation"
        case .feelingsOpinions: base = "a conversation where people have different experiences or preferences"
        case .conflictResolution: base = "an everyday disagreement that needs a calm, fair solution"
        case .socialContacts: base = "a first meeting, invitation, or conversation with neighbors and colleagues"
        case .languageLearning: base = "a German lesson, study group, or exam-feedback conversation"
        case .authorities: base = "an appointment, phone call, or letter involving a public office"
        case .work: base = "a workplace handover, schedule discussion, or team conversation"
        case .jobSearch: base = "a vacancy inquiry, application, or interview"
        case .educationTraining: base = "a course registration, qualification, or education-advice appointment"
        case .bankingInsurance: base = "a payment, account, contract, or insurance inquiry"
        case .childcareEducation: base = "a daycare, school, or parent-teacher conversation"
        case .shopping: base = "a shop, service counter, order, or consumer problem"
        case .health: base = "a medical appointment, pharmacy visit, or health-insurance conversation"
        case .mediaUse: base = "a message, website, news item, app, or online service"
        case .mobility: base = "a journey, ticket purchase, route question, or travel disruption"
        case .classroom: base = "a classroom task that requires clarification and cooperation"
        case .housing: base = "an apartment search, tenancy conversation, or repair request"
        }
        let complexity = switch level {
        case .a1: "You need to exchange the essential facts in short, clear turns."
        case .a2: "You need to connect details, ask follow-up questions, and confirm the result."
        case .b1: "You need to explain the situation, respond to another view, and agree on a justified next step."
        }
        let themeText = theme.map { " The active vocabulary theme is \($0)." } ?? ""
        return "The setting is \(base). \(complexity)\(themeText)"
    }

    private static func transferTask(field: IntegrationActionField, level: CEFRLevel) -> String {
        let task: String
        switch field {
        case .migrationAndIdentity: task = "Explain the relevant personal facts, ask one clarifying question, and confirm what happens next."
        case .feelingsOpinions: task = "State your view, give a reason, react respectfully, and identify one point of agreement."
        case .conflictResolution: task = "Describe the problem without blame, listen to the response, and propose a workable solution."
        case .socialContacts: task = "Open the conversation, exchange information, respond to a detail, and make or decline an arrangement politely."
        case .languageLearning: task = "Identify what is difficult, ask for useful feedback, and choose one specific practice step."
        case .authorities: task = "State your request, identify the relevant document or deadline, and repeat the agreed next step."
        case .work: task = "Explain the work situation, check the other person's understanding, and agree who will do what by when."
        case .jobSearch: task = "Present relevant experience, answer one follow-up question, and ask about the role or next stage."
        case .educationTraining: task = "Explain your goal, compare available routes, and ask about requirements and the next application step."
        case .bankingInsurance: task = "Identify the transaction or contract, explain the issue, and request a written or clearly confirmed solution."
        case .childcareEducation: task = "Share the important observation, ask how the child is doing, and agree on one support step."
        case .shopping: task = "Ask for the product or service, check the key condition, and complete or correct the transaction."
        case .health: task = "Describe the main symptom and duration, answer follow-up questions, and repeat the advice or appointment details."
        case .mediaUse: task = "Identify the source and purpose, extract the key information, and decide on a safe response."
        case .mobility: task = "Explain where you need to go, confirm route and time details, and handle one change or delay."
        case .classroom: task = "Clarify the instruction, contribute your answer, compare it with a partner, and note one correction."
        case .housing: task = "Describe the apartment or problem precisely, ask about costs or responsibility, and agree on the next action."
        }
        if level == .a1 {
            return task.replacingOccurrences(of: ", and", with: ", then")
        }
        return task
    }

    private static func textType(field: IntegrationActionField, level: CEFRLevel) -> String {
        switch field {
        case .migrationAndIdentity: level == .b1 ? "structured personal statement" : "personal-information message"
        case .feelingsOpinions: level == .b1 ? "short opinion text" : "personal message"
        case .conflictResolution: level == .b1 ? "solution-focused complaint" : "problem-and-solution message"
        case .socialContacts: "message or invitation"
        case .languageLearning: "learning reflection"
        case .authorities: level == .b1 ? "formal request" : "appointment or document inquiry"
        case .work: "workplace message"
        case .jobSearch: level == .b1 ? "application paragraph" : "job inquiry"
        case .educationTraining: "course or qualification inquiry"
        case .bankingInsurance: "account or contract inquiry"
        case .childcareEducation: "message to daycare or school"
        case .shopping: level == .a1 ? "shopping note" : "service request"
        case .health: "appointment or health message"
        case .mediaUse: level == .b1 ? "source summary" : "information note"
        case .mobility: "travel inquiry"
        case .classroom: "study note"
        case .housing: level == .b1 ? "documented repair request" : "housing inquiry"
        }
    }

    private static func repairCanDo(field: IntegrationActionField, level: CEFRLevel) -> String {
        switch level {
        case .a1: "I can ask someone in a \(field.title.lowercased()) situation to repeat, show, or speak more slowly."
        case .a2: "I can ask a follow-up question and repeat key details to prevent misunderstanding in this \(field.title.lowercased()) situation."
        case .b1: "I can reformulate an unclear point, check another perspective, and keep this \(field.title.lowercased()) exchange moving."
        }
    }

    private static func participationNote(field: IntegrationActionField) -> String {
        switch field {
        case .migrationAndIdentity: "Personal histories differ. Ask respectfully, avoid assumptions, and distinguish identity from legal or administrative status."
        case .feelingsOpinions: "Democratic coexistence allows disagreement. Critique an idea without devaluing the person."
        case .conflictResolution: "A factual description, active listening, and a documented next step often resolve more than blame."
        case .socialContacts: "Levels of formality vary by setting. Observe how people address one another and ask when unsure."
        case .languageLearning: "Multilingual knowledge is a resource. Compare languages, then practice the German pattern in a meaningful action."
        case .authorities: "Identify the responsible office, keep copies, note deadlines, and ask for written confirmation when the matter is important."
        case .work: "Workplace rights and duties are easier to protect when tasks, hours, safety concerns, and agreements are communicated clearly."
        case .jobSearch: "Qualifications can be shown through certificates, experience, examples, and recognition or further-training routes."
        case .educationTraining: "Education responsibilities and pathways can differ by Land. Use an official or professionally accountable advice service."
        case .bankingInsurance: "Before agreeing, check costs, duration, cancellation terms, and which details are confirmed in writing."
        case .childcareEducation: "Families and institutions share information while the child's well-being, development, and equal opportunity stay central."
        case .shopping: "Receipts, contract terms, dates, and a calm description of the defect make consumer requests easier to assess."
        case .health: "Prepare symptoms, duration, medication, and questions. Ask for clarification rather than guessing about medical instructions."
        case .mediaUse: "Check source, date, evidence, and context before trusting or forwarding a claim."
        case .mobility: "Route, time, platform, validity, and accessibility are separate details; confirm the ones that affect your journey."
        case .classroom: "Participation includes asking questions, giving others space, comparing approaches, and using feedback constructively."
        case .housing: "Keep the contract, handover record, photos, and written communication together when discussing costs or defects."
        }
    }

    private static func orientationCatalogTitle(_ moduleID: String, fallback: String) -> String {
        switch moduleID {
        case "orientation-start": "Grundlagen"
        case "orientation-close": "Teilhabe und Prüfungstraining"
        default: fallback
        }
    }

    private static func orientationCatalogSubtitle(_ moduleID: String, fallback: String) -> String {
        switch moduleID {
        case "orientation-start": "Verlässliche Informationen und selbstständiges Handeln"
        case "orientation-close": "Wissen anwenden und verantwortungsvoll mitgestalten"
        default: fallback
        }
    }

    private static func orientationLesson(
        id: String,
        order: Int,
        moduleID: String,
        title: String,
        goal: String,
        units: Int,
        icon: String,
        points: [String],
        situation: String,
        perspectives: [String],
        action: String,
        checks: [OrientationCheck]
    ) -> OrientationLesson {
        OrientationLesson(
            id: id,
            order: order,
            moduleID: moduleID,
            title: title,
            goal: goal,
            lessonUnits: units,
            icon: icon,
            keyPoints: points,
            situation: situation,
            perspectives: perspectives,
            actionTask: action,
            checks: checks
        )
    }

    private static func check(
        _ question: String,
        _ choices: [String],
        _ answer: String,
        _ explanation: String
    ) -> OrientationCheck {
        OrientationCheck(question: question, choices: choices, answer: answer, explanation: explanation)
    }
}
