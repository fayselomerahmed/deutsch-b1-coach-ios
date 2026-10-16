import SwiftData
import SwiftUI

enum LearningVisualTone: Hashable {
    case primary
    case accent
    case listening
    case speaking
    case correct
    case incorrect
    case neutral

    var color: Color {
        switch self {
        case .primary: CoachTheme.primary
        case .accent: CoachTheme.accent
        case .listening: CoachTheme.listening
        case .speaking: CoachTheme.speaking
        case .correct: CoachTheme.correct
        case .incorrect: CoachTheme.incorrect
        case .neutral: Color.secondary
        }
    }
}

enum VocabularyVisualKind: String, CaseIterable {
    case noun
    case action
    case descriptor
    case connector
    case context

    var title: String {
        switch self {
        case .noun: "Noun map"
        case .action: "Action map"
        case .descriptor: "Description pattern"
        case .connector: "Clause connector"
        case .context: "Meaning in context"
        }
    }
}

struct VocabularyVisualDescriptor: Hashable {
    let primarySymbol: String
    let contextSymbol: String
    let accessibilityHint: String
}

enum VocabularyVisualCatalog {
    static let supportedThemes: Set<String> = [
        "Alltag", "Arbeit", "Argumentation", "Behörden", "Bildung", "Eigenschaften",
        "Einkaufen", "Essen", "Familie", "Freizeit", "Gefühle", "Gesellschaft",
        "Gesundheit", "Kommunikation", "Konflikte", "Konnektoren", "Lernen", "Medien",
        "Menschen", "Prüfung", "Reisen", "Stadt", "Umwelt", "Verkehr", "Wetter",
        "Wohnen", "Zeit", "Ämter"
    ]

    static func kind(article: String?, plural: String?, english: String, theme: String) -> VocabularyVisualKind {
        if article != nil || plural != nil { return .noun }
        if theme == "Konnektoren" || theme == "Argumentation" { return .connector }
        if english.lowercased().hasPrefix("to ") { return .action }
        if ["Eigenschaften", "Gefühle"].contains(theme) { return .descriptor }
        return .context
    }

    private struct SymbolRule {
        let terms: [String]
        let symbol: String
        let hint: String
    }

    private static let symbolRules: [SymbolRule] = [
        SymbolRule(terms: ["buch"], symbol: "book.closed.fill", hint: "a book"),
        SymbolRule(terms: ["ubung"], symbol: "checklist", hint: "a learning exercise"),
        SymbolRule(terms: ["bewegung"], symbol: "figure.walk", hint: "physical exercise"),
        SymbolRule(terms: ["erkaltung"], symbol: "bandage.fill", hint: "a common cold"),
        SymbolRule(terms: ["to be"], symbol: "person.fill", hint: "being or identity"),
        SymbolRule(terms: ["to have"], symbol: "hand.raised.fill", hint: "having something"),
        SymbolRule(terms: ["to live", "to stay"], symbol: "house.fill", hint: "living or staying somewhere"),
        SymbolRule(terms: ["to do"], symbol: "checkmark.circle.fill", hint: "doing an action"),
        SymbolRule(terms: ["country", "origin"], symbol: "globe.europe.africa.fill", hint: "a country or place of origin"),
        SymbolRule(terms: ["city"], symbol: "building.2.fill", hint: "a city"),
        SymbolRule(terms: ["address"], symbol: "mappin.and.ellipse", hint: "a location or address"),
        SymbolRule(terms: ["name"], symbol: "person.text.rectangle.fill", hint: "a person's name"),
        SymbolRule(terms: ["mother", "father", "parents", "family", "brother", "sister", "son", "daughter", "husband", "wife", "grandmother", "grandfather", "aunt", "uncle", "cousin", "grandson"], symbol: "person.3.fill", hint: "family and people"),
        SymbolRule(terms: ["child", "student"], symbol: "figure.child", hint: "a young person"),
        SymbolRule(terms: ["friend", "neighbor", "colleague", "team", "community", "together", "group work", "solidarity", "coexistence"], symbol: "person.2.fill", hint: "people together"),
        SymbolRule(terms: ["teacher", "course instructor", "examiner", "caseworker", "manager", "boss", "employer", "employee", "tenant", "landlord", "caretaker", "driver", "member"], symbol: "person.crop.circle.fill", hint: "a person in a role"),
        SymbolRule(terms: ["man", "woman", "person", "public", "population"], symbol: "person.fill", hint: "a person"),

        SymbolRule(terms: ["apartment", "house", "room", "accommodation", "hostel", "neighborhood", "basement", "balcony"], symbol: "house.fill", hint: "a home or place to stay"),
        SymbolRule(terms: ["door"], symbol: "door.left.hand.closed", hint: "a door"),
        SymbolRule(terms: ["window"], symbol: "window.vertical.closed", hint: "a window"),
        SymbolRule(terms: ["bed", "sleep", "lack of sleep"], symbol: "bed.double.fill", hint: "sleep and rest"),
        SymbolRule(terms: ["key", "key handover", "access"], symbol: "key.fill", hint: "a key or access"),
        SymbolRule(terms: ["kitchen", "cook"], symbol: "frying.pan.fill", hint: "cooking in a kitchen"),
        SymbolRule(terms: ["bathroom", "shower", "wash"], symbol: "shower.fill", hint: "washing and bathing"),
        SymbolRule(terms: ["garden", "nature", "agriculture"], symbol: "leaf.fill", hint: "plants and nature"),
        SymbolRule(terms: ["furniture", "table", "chair"], symbol: "chair.lounge.fill", hint: "home furniture"),
        SymbolRule(terms: ["roof", "heating", "repair", "defect"], symbol: "wrench.and.screwdriver.fill", hint: "a home feature or repair"),

        SymbolRule(terms: ["bread", "breakfast", "lunch", "dinner", "meal", "meat", "rice", "cheese", "egg", "soup", "salad", "potato"], symbol: "fork.knife", hint: "food or a meal"),
        SymbolRule(terms: ["apple"], symbol: "leaf.fill", hint: "an apple"),
        SymbolRule(terms: ["banana"], symbol: "leaf.fill", hint: "a banana"),
        SymbolRule(terms: ["vegetables", "nutrition"], symbol: "carrot.fill", hint: "fresh vegetables and nutrition"),
        SymbolRule(terms: ["water", "milk", "thirst"], symbol: "drop.fill", hint: "a drink"),
        SymbolRule(terms: ["coffee", "tea"], symbol: "cup.and.saucer.fill", hint: "a warm drink"),
        SymbolRule(terms: ["bottle"], symbol: "waterbottle.fill", hint: "a bottle"),
        SymbolRule(terms: ["sugar", "salt"], symbol: "takeoutbag.and.cup.and.straw.fill", hint: "a food ingredient"),
        SymbolRule(terms: ["hunger", "eat", "drink"], symbol: "fork.knife.circle.fill", hint: "eating or drinking"),

        SymbolRule(terms: ["supermarket", "market", "shop", "checkout", "offer", "price", "buy", "order"], symbol: "cart.fill", hint: "shopping"),
        SymbolRule(terms: ["bag", "luggage"], symbol: "suitcase.fill", hint: "a bag or luggage"),
        SymbolRule(terms: ["money", "euro", "salary", "fee", "rent", "utility costs", "deposit", "cost", "expensive", "cheap", "pay", "transfer money", "save"], symbol: "eurosign.circle.fill", hint: "money and cost"),
        SymbolRule(terms: ["bill", "receipt", "invoice"], symbol: "doc.text.fill", hint: "a bill or receipt"),
        SymbolRule(terms: ["kilogram", "size", "comparison", "compare", "weighing of options"], symbol: "scalemass.fill", hint: "size or comparison"),
        SymbolRule(terms: ["color", "beautiful"], symbol: "paintpalette.fill", hint: "color and appearance"),

        SymbolRule(terms: ["bus", "means of transport", "public transport"], symbol: "bus.fill", hint: "a bus"),
        SymbolRule(terms: ["train", "subway", "tram", "train station", "platform", "platform track", "connection"], symbol: "tram.fill", hint: "rail travel"),
        SymbolRule(terms: ["car", "taxi"], symbol: "car.fill", hint: "a car"),
        SymbolRule(terms: ["bicycle"], symbol: "bicycle", hint: "a bicycle"),
        SymbolRule(terms: ["airplane", "airport"], symbol: "airplane", hint: "air travel"),
        SymbolRule(terms: ["ticket", "admission ticket"], symbol: "ticket.fill", hint: "a ticket"),
        SymbolRule(terms: ["traffic light", "stop"], symbol: "stop.circle.fill", hint: "a traffic signal or stop"),
        SymbolRule(terms: ["way", "street", "travel destination", "trip", "excursion", "hike"], symbol: "map.fill", hint: "a route or destination"),
        SymbolRule(terms: ["departure", "arrival", "delay", "timetable", "schedule", "outward and return journey"], symbol: "clock.arrow.circlepath", hint: "a timed journey"),
        SymbolRule(terms: ["reservation", "to book", "reserve"], symbol: "calendar.badge.checkmark", hint: "a reservation"),
        SymbolRule(terms: ["travel guide", "sight", "culture"], symbol: "binoculars.fill", hint: "a place to discover"),

        SymbolRule(terms: ["day", "week", "year", "monday", "weekend", "date", "today", "tomorrow", "calendar"], symbol: "calendar", hint: "a date on the calendar"),
        SymbolRule(terms: ["clock", "minute", "hour", "time of day", "working hours", "consultation hours", "office hours", "waiting time", "processing time", "deadline", "in time", "punctual", "time management", "overtime hour"], symbol: "clock.fill", hint: "time"),
        SymbolRule(terms: ["evening", "night"], symbol: "moon.stars.fill", hint: "evening or night"),
        SymbolRule(terms: ["break", "recovery", "relaxed", "rest"], symbol: "cup.and.saucer.fill", hint: "a restorative pause"),

        SymbolRule(terms: ["sun", "sunny", "warm", "heatwave"], symbol: "sun.max.fill", hint: "sun and warmth"),
        SymbolRule(terms: ["rain", "rainy"], symbol: "cloud.rain.fill", hint: "rain"),
        SymbolRule(terms: ["snow", "cold"], symbol: "snowflake", hint: "snow or cold"),
        SymbolRule(terms: ["wind", "windy", "air"], symbol: "wind", hint: "wind and air"),
        SymbolRule(terms: ["cloud", "weather"], symbol: "cloud.sun.fill", hint: "the weather"),
        SymbolRule(terms: ["temperature", "degree", "fever"], symbol: "thermometer.medium", hint: "temperature"),
        SymbolRule(terms: ["dry"], symbol: "drop.degreesign.slash.fill", hint: "dry conditions"),

        SymbolRule(terms: ["doctor", "female doctor", "medical practice", "consultation", "examination", "treatment", "preventive care"], symbol: "stethoscope", hint: "medical care"),
        SymbolRule(terms: ["nurse", "hospital", "emergency", "care provision"], symbol: "cross.case.fill", hint: "health care"),
        SymbolRule(terms: ["medicine", "prescription", "side effect", "pharmacist", "pharmacy"], symbol: "pills.fill", hint: "medicine"),
        SymbolRule(terms: ["vaccination"], symbol: "syringe.fill", hint: "a vaccination"),
        SymbolRule(terms: ["head", "knowledge", "ability", "competence", "idea", "opinion", "perspective", "consider", "assess", "decide"], symbol: "brain.head.profile", hint: "thinking and understanding"),
        SymbolRule(terms: ["hand", "support", "help", "lend or borrow", "hand in", "give", "take"], symbol: "hand.raised.fill", hint: "a helping hand"),
        SymbolRule(terms: ["eye", "see", "viewing", "perceive"], symbol: "eye.fill", hint: "seeing"),
        SymbolRule(terms: ["ear", "hear", "listening comprehension"], symbol: "ear.fill", hint: "hearing and listening"),
        SymbolRule(terms: ["mouth", "speak", "say", "pronunciation", "expression"], symbol: "waveform", hint: "speaking"),
        SymbolRule(terms: ["body", "exercise", "leg", "back", "stomach", "throat", "blood pressure", "well-being", "healthy", "health"], symbol: "figure.walk", hint: "the body and health"),
        SymbolRule(terms: ["pain", "injury", "strain", "allergy", "symptom", "cough", "cold", "sick"], symbol: "bandage.fill", hint: "a health problem"),
        SymbolRule(terms: ["dentist"], symbol: "mouth.fill", hint: "dental care"),
        SymbolRule(terms: ["insurance", "health insurer", "health insurance card"], symbol: "shield.checkered", hint: "insurance protection"),
        SymbolRule(terms: ["balance"], symbol: "scale.3d", hint: "balance"),

        SymbolRule(terms: ["work", "profession", "workplace", "company", "department", "activity", "shift", "part-time position", "part-time work", "full-time work", "workload", "working atmosphere", "career"], symbol: "briefcase.fill", hint: "work"),
        SymbolRule(terms: ["job application", "cv", "job interview", "employment reference", "qualification", "vocational training", "professional training", "continuing education"], symbol: "person.text.rectangle.fill", hint: "professional development"),
        SymbolRule(terms: ["meeting", "conversation", "discussion", "teamwork"], symbol: "person.2.fill", hint: "people working together"),
        SymbolRule(terms: ["contract", "employment contract", "rental contract", "house rules", "employment law", "examination regulations", "rule", "regulation"], symbol: "doc.badge.gearshape.fill", hint: "a formal rule or contract"),
        SymbolRule(terms: ["termination", "unemployment", "cancel", "cancellation", "rejection"], symbol: "xmark.seal.fill", hint: "an ending or rejection"),
        SymbolRule(terms: ["promotion", "progress", "learning success", "advantageous", "improve", "promote"], symbol: "chart.line.uptrend.xyaxis", hint: "growth and progress"),
        SymbolRule(terms: ["responsibility", "responsible", "reliable", "requirement", "required", "necessary", "condition"], symbol: "checkmark.shield.fill", hint: "responsibility or a requirement"),
        SymbolRule(terms: ["experience", "probation period", "performance pressure"], symbol: "gauge.with.dots.needle.67percent", hint: "experience or performance"),

        SymbolRule(terms: ["course", "lesson", "class", "teaching method", "learning objective", "learning strategy", "exam preparation", "continuing education opportunity"], symbol: "graduationcap.fill", hint: "learning and education"),
        SymbolRule(terms: ["task", "exercise", "homework", "exam", "task instructions", "assessment criterion", "evaluation"], symbol: "checklist", hint: "a learning task"),
        SymbolRule(terms: ["book", "notebook", "dictionary", "reading comprehension", "read"], symbol: "book.closed.fill", hint: "reading and study"),
        SymbolRule(terms: ["pen", "write", "signature", "sign", "in writing"], symbol: "pencil", hint: "writing"),
        SymbolRule(terms: ["computer", "screen time", "user account", "media literacy"], symbol: "desktopcomputer", hint: "digital work"),
        SymbolRule(terms: ["board", "paper", "example", "summary", "conclusion", "introduction"], symbol: "doc.richtext.fill", hint: "written learning material"),
        SymbolRule(terms: ["question", "questionnaire", "follow-up question", "ask", "ask again"], symbol: "questionmark.bubble.fill", hint: "a question"),
        SymbolRule(terms: ["answer", "response", "feedback", "reply"], symbol: "checkmark.bubble.fill", hint: "an answer or feedback"),
        SymbolRule(terms: ["exam anxiety", "fear", "worry", "nervous"], symbol: "exclamationmark.triangle.fill", hint: "worry or anxiety"),

        SymbolRule(terms: ["word", "sentence", "language", "useful phrase", "language mediation", "spell", "repeat", "understand", "explain", "describe", "clarify", "summarize"], symbol: "text.bubble.fill", hint: "language and meaning"),
        SymbolRule(terms: ["email", "message", "invitation", "announcement", "information", "report", "publication", "media coverage", "false report"], symbol: "envelope.fill", hint: "a message or publication"),
        SymbolRule(terms: ["phone", "phone number", "call", "reachable"], symbol: "phone.fill", hint: "a phone call"),
        SymbolRule(terms: ["discussion", "argument", "counterargument", "claim", "objection", "point of view", "statement", "state an opinion", "justify", "convince", "disagree", "agree"], symbol: "bubble.left.and.bubble.right.fill", hint: "an exchange of ideas"),
        SymbolRule(terms: ["suggestion", "proposed solution", "proposed approach", "solution", "recommend", "suggest"], symbol: "lightbulb.fill", hint: "a helpful idea"),
        SymbolRule(terms: ["agreement", "arrange", "appointment", "appointment confirmation", "appointment change", "meeting point"], symbol: "calendar.badge.checkmark", hint: "an agreement or appointment"),
        SymbolRule(terms: ["misunderstanding", "complaint", "conflict", "apology", "apologize"], symbol: "exclamationmark.bubble.fill", hint: "a communication problem"),

        SymbolRule(terms: ["form", "application", "document", "copy", "certificate", "proof", "reference number", "registration certificate", "certificate of participation"], symbol: "doc.text.fill", hint: "an official document"),
        SymbolRule(terms: ["passport", "identity card", "residence permit"], symbol: "person.text.rectangle.fill", hint: "an identity document"),
        SymbolRule(terms: ["registration", "register"], symbol: "person.badge.plus", hint: "official registration"),
        SymbolRule(terms: ["authority", "town hall", "citizens' office", "residents' registration office", "immigration office", "post office", "bank", "police", "legal advice"], symbol: "building.columns.fill", hint: "a public office"),
        SymbolRule(terms: ["approval", "permit", "entitlement", "confirm", "agreement"], symbol: "checkmark.seal.fill", hint: "approval"),
        SymbolRule(terms: ["appeal", "objection", "legal remedy", "procedure", "processing status", "responsibility", "power of attorney"], symbol: "scalemass.fill", hint: "an official or legal process"),

        SymbolRule(terms: ["club", "event", "exhibition", "concert", "hobby", "celebration", "celebrate", "play"], symbol: "party.popper.fill", hint: "a social or leisure activity"),
        SymbolRule(terms: ["sports hall", "run", "hike"], symbol: "figure.run", hint: "sport and movement"),
        SymbolRule(terms: ["library"], symbol: "books.vertical.fill", hint: "a library"),
        SymbolRule(terms: ["joy", "happy", "satisfied", "friendly", "polite", "support"], symbol: "face.smiling.fill", hint: "a positive feeling"),
        SymbolRule(terms: ["sad", "fear", "worry", "nervous", "strain"], symbol: "cloud.rain.fill", hint: "a difficult feeling"),
        SymbolRule(terms: ["heart", "feeling", "well-being"], symbol: "heart.fill", hint: "a feeling"),

        SymbolRule(terms: ["waste", "wastefulness", "waste prevention", "recycling"], symbol: "arrow.3.trianglepath", hint: "waste and recycling"),
        SymbolRule(terms: ["energy", "electricity", "energy consumption", "renewable energy"], symbol: "bolt.fill", hint: "energy"),
        SymbolRule(terms: ["climate change", "emission", "environmental awareness", "sustainability", "sustainable", "resource"], symbol: "leaf.fill", hint: "the environment"),
        SymbolRule(terms: ["noise"], symbol: "speaker.wave.3.fill", hint: "loud sound"),
        SymbolRule(terms: ["packaging"], symbol: "shippingbox.fill", hint: "packaging"),

        SymbolRule(terms: ["data protection", "data protection provision", "privacy"], symbol: "lock.shield.fill", hint: "digital privacy"),
        SymbolRule(terms: ["network"], symbol: "network", hint: "a network"),
        SymbolRule(terms: ["advertising", "announcement", "draw attention"], symbol: "megaphone.fill", hint: "public attention"),
        SymbolRule(terms: ["survey"], symbol: "chart.bar.doc.horizontal.fill", hint: "a survey"),
        SymbolRule(terms: ["source", "evidence"], symbol: "magnifyingglass", hint: "a source or evidence"),
        SymbolRule(terms: ["freedom of expression"], symbol: "quote.bubble.fill", hint: "freedom to speak"),

        SymbolRule(terms: ["big", "small", "different", "similar", "long-term", "detailed", "clear", "flexible"], symbol: "arrow.left.and.right", hint: "a visible quality or comparison"),
        SymbolRule(terms: ["fast", "slow"], symbol: "speedometer", hint: "speed"),
        SymbolRule(terms: ["new", "old", "young"], symbol: "clock.arrow.circlepath", hint: "age or change over time"),
        SymbolRule(terms: ["good", "appropriate", "advantage", "possible", "available", "free of charge"], symbol: "hand.thumbsup.fill", hint: "a positive quality"),
        SymbolRule(terms: ["bad", "disadvantage", "impossible", "absent"], symbol: "hand.thumbsdown.fill", hint: "a negative quality"),
        SymbolRule(terms: ["urgent", "essential", "decisive"], symbol: "exclamationmark.circle.fill", hint: "something important"),
        SymbolRule(terms: ["quiet", "comfortable", "careful"], symbol: "leaf.fill", hint: "a calm quality"),

        SymbolRule(terms: ["go", "come", "travel", "move home", "pick up", "visit"], symbol: "figure.walk.motion", hint: "movement from one place to another"),
        SymbolRule(terms: ["get up", "begin", "prepare"], symbol: "sunrise.fill", hint: "starting an activity"),
        SymbolRule(terms: ["open", "close"], symbol: "door.left.hand.open", hint: "opening or closing"),
        SymbolRule(terms: ["look for", "find"], symbol: "magnifyingglass", hint: "searching and finding"),
        SymbolRule(terms: ["clean"], symbol: "sparkles", hint: "cleaning"),
        SymbolRule(terms: ["wear or carry"], symbol: "tshirt.fill", hint: "clothing or carrying"),
        SymbolRule(terms: ["send", "deliver", "inform", "provide information", "tell", "mention"], symbol: "paperplane.fill", hint: "sending information"),
        SymbolRule(terms: ["fill out", "sign", "apply for", "prove"], symbol: "pencil.and.list.clipboard", hint: "completing a formal task"),
        SymbolRule(terms: ["plan", "arrange", "prepare", "take care of", "implement", "ensure"], symbol: "checklist", hint: "planning and completing a task"),
        SymbolRule(terms: ["remember"], symbol: "brain.fill", hint: "remembering"),
        SymbolRule(terms: ["change", "extend", "postpone", "return", "miss", "avoid", "do without"], symbol: "arrow.triangle.2.circlepath", hint: "a change of plan"),
        SymbolRule(terms: ["participate", "volunteering", "participation", "integration", "diversity", "equal opportunity", "sense of belonging"], symbol: "person.3.fill", hint: "participating in society"),
        SymbolRule(terms: ["support", "enable", "recognize", "consideration", "mutual"], symbol: "hands.and.sparkles.fill", hint: "support and consideration")
    ]

    static func descriptor(theme: String, german: String, english: String) -> VocabularyVisualDescriptor {
        let normalizedEnglish = normalize(english)
        let normalizedGerman = normalize(german)
        let match = symbolRules.first { rule in
            rule.terms.contains { term in
                contains(term: normalize(term), in: normalizedEnglish)
                    || contains(term: normalize(term), in: normalizedGerman)
            }
        }
        let context = contextSymbol(theme: theme)
        let primary = match?.symbol ?? context
        return VocabularyVisualDescriptor(
            primarySymbol: primary,
            contextSymbol: primary == context ? secondaryContextSymbol(theme: theme) : context,
            accessibilityHint: match?.hint ?? "the real-world context of \(theme.lowercased())"
        )
    }

    static func symbol(theme: String, german: String, english: String) -> String {
        descriptor(theme: theme, german: german, english: english).primarySymbol
    }

    static func pictogram(german: String, english: String) -> String? {
        let exactEnglish = normalize(english)
        let exactGerman = normalize(german)
        let pictograms: [String: String] = [
            "day": "📅", "week": "🗓️", "year": "📆", "date": "📅",
            "monday": "🗓️", "weekend": "🎉", "evening": "🌆", "night": "🌙",
            "hour": "🕐", "minute": "⏱️", "waiting time": "⏳", "time of day": "🕒",
            "mother": "👩", "father": "👨", "child": "🧒",
            "brother": "👦", "sister": "👧", "son": "👦", "daughter": "👧",
            "husband": "👨", "wife": "👩", "parents": "👪", "family": "👨‍👩‍👧‍👦",
            "grandmother": "👵", "grandfather": "👴", "aunt": "👩", "uncle": "👨",
            "cousin": "🧑", "grandson": "👦", "friend": "🧑‍🤝‍🧑", "neighbor": "🏘️",
            "man": "👨", "woman": "👩", "student": "🧑‍🎓", "teacher": "🧑‍🏫",
            "boss": "🧑‍💼", "colleague": "👥", "driver": "🧑‍✈️", "nurse": "🧑‍⚕️",
            "dentist": "🦷", "female doctor": "👩‍⚕️",
            "apple": "🍎", "apfel": "🍎",
            "banana": "🍌", "banane": "🍌",
            "bread": "🍞", "brot": "🍞",
            "coffee": "☕️", "kaffee": "☕️",
            "water": "💧", "wasser": "💧",
            "milk": "🥛", "milch": "🥛",
            "tea": "🍵", "tee": "🍵",
            "potato": "🥔", "kartoffel": "🥔",
            "rice": "🍚", "reis": "🍚",
            "cheese": "🧀", "kase": "🧀",
            "meat": "🥩", "fleisch": "🥩",
            "vegetables": "🥕", "gemuse": "🥕",
            "egg": "🥚", "ei": "🥚",
            "soup": "🍲", "suppe": "🍲",
            "salad": "🥗", "salat": "🥗",
            "breakfast": "🍳", "fruhstuck": "🍳",
            "lunch": "🍽️", "mittagessen": "🍽️",
            "dinner": "🍽️", "abendessen": "🍽️",
            "sugar": "🍬", "zucker": "🍬",
            "salt": "🧂", "salz": "🧂",
            "house": "🏠", "haus": "🏠",
            "apartment": "🏢", "wohnung": "🏢",
            "room": "🛋️", "zimmer": "🛋️",
            "door": "🚪", "tur": "🚪",
            "window": "🪟", "fenster": "🪟",
            "table": "🪑", "tisch": "🪑",
            "chair": "🪑", "stuhl": "🪑",
            "bed": "🛏️", "bett": "🛏️",
            "key": "🔑", "schlussel": "🔑",
            "garden": "🌻", "garten": "🌻",
            "address": "📍", "country": "🌍", "city": "🏙️", "street": "🛣️",
            "way": "🗺️", "park": "🌳", "restaurant": "🍽️", "school": "🏫",
            "bank": "🏦", "post office": "📮", "police": "👮",
            "town hall": "🏛️", "citizens office": "🏛️", "pharmacy": "⚕️",
            "train station": "🚉", "platform": "🚉", "stop": "🚏",
            "bus": "🚌", "train": "🚆", "zug": "🚆",
            "car": "🚗", "auto": "🚗",
            "bicycle": "🚲", "fahrrad": "🚲",
            "taxi": "🚕", "subway": "🚇", "tram": "🚋", "airport": "🛫",
            "airplane": "✈️", "flugzeug": "✈️",
            "ticket": "🎫", "fahrkarte": "🎫",
            "traffic light": "🚦", "ampel": "🚦",
            "trip": "🧳",
            "clock": "🕒", "uhr": "🕒",
            "sun": "☀️", "sonne": "☀️",
            "rain": "🌧️", "regen": "🌧️",
            "snow": "❄️", "schnee": "❄️",
            "wind": "💨", "cloud": "☁️", "wolke": "☁️",
            "weather": "🌦️", "temperature": "🌡️", "degree": "🌡️",
            "book": "📘", "buch": "📘",
            "notebook": "📓", "heft": "📓",
            "pen": "🖊️", "stift": "🖊️",
            "dictionary": "📖", "board": "📋", "paper": "📄",
            "lesson": "🎓", "class": "🏫", "course": "🎓",
            "task": "✅", "exercise": "📝", "homework": "✍️", "exam": "📝",
            "example": "💡", "question": "❓", "answer": "✅",
            "word": "🔤", "sentence": "💬", "language": "🗣️",
            "computer": "💻",
            "phone number": "📱", "telefonnummer": "📱",
            "email": "✉️", "e mail": "✉️",
            "form": "📋", "document": "📄", "copy": "📑",
            "bill": "🧾", "receipt": "🧾", "appointment": "📅",
            "name": "🪪", "number": "🔢",
            "medicine": "💊", "medikament": "💊",
            "hospital": "🏥", "krankenhaus": "🏥",
            "doctor": "🩺", "arzt": "🩺",
            "head": "👤", "hand": "✋", "eye": "👁️", "ear": "👂",
            "mouth": "👄", "body": "🧍", "leg": "🦵", "back": "🧍",
            "stomach": "🫃", "throat": "🗣️", "pain": "🤕",
            "hunger": "🍽️", "thirst": "🥤",
            "money": "💶", "geld": "💶",
            "euro": "💶",
            "price": "🏷️", "offer": "🏷️", "checkout": "🧾", "kilogram": "⚖️",
            "bag": "🛍️", "tasche": "🛍️",
            "supermarket": "🛒", "supermarkt": "🛒",
            "market": "🧺", "markt": "🧺",
            "bottle": "🍶", "flasche": "🍶",
            "work": "💼", "profession": "💼", "office": "🏢",
            "break": "☕️", "color": "🎨",
            "joy": "😊", "fear": "😨", "worry": "😟"
        ]
        return pictograms[exactEnglish] ?? pictograms[exactGerman]
    }

    private static func contextSymbol(theme: String) -> String {
        switch theme {
        case "Alltag": return "figure.walk"
        case "Arbeit": return "briefcase.fill"
        case "Argumentation": return "text.bubble.fill"
        case "Behörden", "Ämter": return "building.columns.fill"
        case "Bildung", "Lernen", "Prüfung": return "graduationcap.fill"
        case "Eigenschaften": return "slider.horizontal.3"
        case "Einkaufen": return "cart.fill"
        case "Essen": return "fork.knife"
        case "Familie", "Menschen", "Gesellschaft": return "person.2.fill"
        case "Freizeit": return "figure.run"
        case "Gefühle": return "heart.fill"
        case "Gesundheit": return "cross.case.fill"
        case "Kommunikation": return "bubble.left.and.bubble.right.fill"
        case "Konflikte": return "exclamationmark.bubble.fill"
        case "Konnektoren": return "link"
        case "Medien": return "newspaper.fill"
        case "Reisen": return "suitcase.rolling.fill"
        case "Stadt": return "building.2.fill"
        case "Umwelt": return "leaf.fill"
        case "Verkehr": return "bus.fill"
        case "Wetter": return "cloud.sun.fill"
        case "Wohnen": return "house.fill"
        case "Zeit": return "calendar"
        default: return "photo.fill"
        }
    }

    private static func secondaryContextSymbol(theme: String) -> String {
        switch theme {
        case "Alltag", "Eigenschaften": return "arrow.right"
        case "Argumentation", "Kommunikation", "Konnektoren", "Konflikte": return "quote.bubble.fill"
        case "Arbeit", "Behörden", "Ämter": return "doc.text.fill"
        case "Bildung", "Lernen", "Prüfung": return "book.closed.fill"
        case "Einkaufen", "Essen": return "bag.fill"
        case "Familie", "Menschen", "Gesellschaft": return "heart.fill"
        case "Freizeit": return "figure.run"
        case "Gefühle": return "face.smiling.fill"
        case "Gesundheit": return "heart.text.square.fill"
        case "Medien": return "text.bubble.fill"
        case "Reisen", "Verkehr": return "map.fill"
        case "Stadt": return "mappin.and.ellipse"
        case "Umwelt", "Wetter": return "sun.max.fill"
        case "Wohnen": return "key.fill"
        case "Zeit": return "clock.fill"
        default: return "photo.fill"
        }
    }

    private static func normalize(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9 ]"#, with: " ", options: .regularExpression)
            .split(separator: " ")
            .joined(separator: " ")
    }

    private static func contains(term: String, in value: String) -> Bool {
        value == term || " \(value) ".contains(" \(term) ")
    }
}

struct VocabularyMemoryPicture: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPresented = false

    let word: VocabWord
    var compact = false
    var featured = false

    private var objectSide: CGFloat {
        compact ? 92 : featured ? 170 : 132
    }

    private var fallbackSide: CGFloat {
        compact ? 86 : featured ? 162 : 124
    }

    private var canvasHeight: CGFloat {
        compact ? 112 : featured ? 208 : 164
    }

    private var descriptor: VocabularyVisualDescriptor {
        VocabularyVisualCatalog.descriptor(theme: word.theme, german: word.german, english: word.english)
    }

    private var pictogram: String? {
        VocabularyVisualCatalog.pictogram(german: word.german, english: word.english)
    }

    private var objectImage: UIImage? {
        VocabularyObjectAtlas.image(for: word)
    }

    private var kind: VocabularyVisualKind {
        VocabularyVisualCatalog.kind(
            article: word.article,
            plural: word.plural,
            english: word.english,
            theme: word.theme
        )
    }

    private var tint: Color {
        switch word.theme {
        case "Arbeit", "Behörden", "Ämter": CoachTheme.listening
        case "Gesundheit", "Gefühle": CoachTheme.speaking
        case "Umwelt", "Wetter", "Wohnen": CoachTheme.primary
        case "Argumentation", "Kommunikation", "Konflikte", "Konnektoren": CoachTheme.accent
        case "Bildung", "Lernen", "Prüfung": CoachTheme.reward
        default: CoachTheme.reading
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface,
                    tint.opacity(0.16),
                    CoachTheme.rewardGlow.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Group {
                if let objectImage {
                    Image(uiImage: objectImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: objectSide, height: objectSide)
                        .clipShape(RoundedRectangle(cornerRadius: compact ? 20 : 26, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: compact ? 20 : 26, style: .continuous)
                                .stroke(.white.opacity(0.72), lineWidth: 1)
                        }
                        .shadow(color: tint.opacity(0.20), radius: compact ? 7 : 12, y: compact ? 4 : 7)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: compact ? 20 : 26, style: .continuous)
                            .fill(CoachTheme.elevatedSurface.opacity(0.96))
                            .overlay {
                                RoundedRectangle(cornerRadius: compact ? 20 : 26, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [tint.opacity(0.18), tint.opacity(0.04)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: compact ? 20 : 26, style: .continuous)
                                    .stroke(.white.opacity(0.50), lineWidth: 1)
                            }
                            .shadow(color: tint.opacity(0.18), radius: compact ? 7 : 12, y: compact ? 4 : 7)

                        if let pictogram {
                            Text(pictogram)
                                .font(.system(size: compact ? 52 : 76))
                                .minimumScaleFactor(0.8)
                                .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                        } else {
                            Image(systemName: descriptor.primarySymbol)
                                .font(.system(size: compact ? 45 : 66, weight: .semibold))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(tint, tint.opacity(0.42))
                        }
                    }
                    .frame(width: fallbackSide, height: fallbackSide)
                }
            }
            .scaleEffect(isPresented ? 1 : 0.88)
            .offset(y: isPresented ? 0 : 5)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: canvasHeight)
        .clipShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke(tint.opacity(0.16), lineWidth: 1)
        }
        .onAppear {
            guard !isPresented else { return }
            if reduceMotion {
                isPresented = true
            } else {
                withAnimation(CoachMotion.quick) {
                    isPresented = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .teachingAccessibilityLabel(
            "Picture for \(word.german): \(descriptor.accessibilityHint)",
            protectedGerman: [word.german]
        )
    }
}

struct VocabularyVisualExplanation: View {
    let word: VocabWord
    var compact = false
    var showsIdentity = true
    var showsExample = true
    var prefersVisualRecall = false
    @State private var revealsMeaning = false

    private var kind: VocabularyVisualKind {
        VocabularyVisualCatalog.kind(
            article: word.article,
            plural: word.plural,
            english: word.english,
            theme: word.theme
        )
    }

    private var symbol: String {
        VocabularyVisualCatalog.symbol(theme: word.theme, german: word.german, english: word.english)
    }

    private var lemma: String {
        guard let article = word.article else { return word.german }
        let prefix = article + " "
        guard word.german.lowercased().hasPrefix(prefix.lowercased()) else { return word.german }
        return String(word.german.dropFirst(prefix.count))
    }

    private var displayGerman: String {
        guard let article = word.article else { return word.german }
        return word.german.lowercased().hasPrefix(article.lowercased() + " ")
            ? word.german
            : "\(article) \(word.german)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 9 : 12) {
            if showsIdentity {
                HStack(spacing: 12) {
                    CoachIconTile(icon: symbol, tint: CoachTheme.accent, size: compact ? 42 : 50)
                    VStack(alignment: .leading, spacing: 3) {
                        GermanVocabularyTitle(
                            word: word,
                            font: compact ? .headline : .system(.title3, design: .rounded, weight: .bold)
                        )
                        .foregroundStyle(.primary)
                        if !prefersVisualRecall || revealsMeaning {
                            TeachingText(english: word.english)
                                .font(compact ? .caption : .callout)
                                .foregroundStyle(.secondary)
                        } else {
                            Button {
                                withAnimation(CoachMotion.quick) { revealsMeaning = true }
                            } label: {
                                TeachingLabel(english: "Reveal meaning", systemImage: "eye")
                                    .font(.caption.weight(.semibold))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(CoachTheme.primary)
                            .teachingAccessibilityHint("Shows the support-language meaning after visual recall")
                        }
                    }
                    Spacer(minLength: 4)
                    TeachingText(english: kind.title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CoachTheme.primary)
                        .multilineTextAlignment(.trailing)
                }
            } else {
                HStack(spacing: 10) {
                    CoachIconTile(icon: symbol, tint: CoachTheme.accent, size: 42)
                    VStack(alignment: .leading, spacing: 2) {
                        TeachingText(english: kind.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoachTheme.primary)
                        Text(word.theme)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }

            if !compact {
                VocabularyMemoryPicture(word: word)
            }

            diagram

            if !compact, let compoundBuilder = CompoundWordBuilder(word: lemma) {
                compoundBuilder
            }

            if showsExample {
                Divider()
                VocabularyExampleSentence(
                    word: word,
                    target: lemma,
                    compact: compact,
                    hidesTranslationUntilRequested: prefersVisualRecall
                )
            }
        }
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel(
            "\(kind.title). \(displayGerman) means \(word.english). Example: \(word.exampleSentence). Translation: \(word.exampleMeaning)",
            protectedGerman: [displayGerman, word.exampleSentence]
        )
    }

    @ViewBuilder private var diagram: some View {
        switch kind {
        case .noun:
            nounDiagram
        case .action:
            conceptFlow(
                leftIcon: "person.fill",
                center: lemma,
                centerCaption: "action",
                rightIcon: symbol
            )
        case .descriptor:
            conceptFlow(
                leftIcon: "person.fill",
                center: "sein + \(lemma)",
                centerCaption: "describes",
                rightIcon: symbol
            )
        case .connector:
            HStack(spacing: 7) {
                visualNode("Clause 1", caption: "idea", tone: .listening, translatesTitle: true)
                Image(systemName: "link").foregroundStyle(CoachTheme.accent)
                visualNode(lemma, caption: "connects", tone: .accent)
                Image(systemName: "arrow.right").foregroundStyle(.secondary)
                visualNode("Clause 2", caption: "idea", tone: .speaking, translatesTitle: true)
            }
        case .context:
            conceptFlow(
                leftIcon: symbol,
                center: lemma,
                centerCaption: word.theme.lowercased(),
                rightIcon: "text.quote",
                translatesCaption: false
            )
        }
    }

    private var nounDiagram: some View {
        GermanNounForms(word: word, prominent: !compact)
    }

    private func conceptFlow(
        leftIcon: String,
        center: String,
        centerCaption: String,
        rightIcon: String,
        translatesCaption: Bool = true
    ) -> some View {
        HStack(spacing: 7) {
            visualIconNode(leftIcon, tone: .listening)
            Image(systemName: "arrow.right").font(.caption).foregroundStyle(.secondary)
            visualNode(
                center,
                caption: centerCaption,
                tone: .primary,
                translatesCaption: translatesCaption
            )
            Image(systemName: "arrow.right").font(.caption).foregroundStyle(.secondary)
            visualIconNode(rightIcon, tone: .accent)
        }
    }

    private func visualNode(
        _ title: String,
        caption: String,
        tone: LearningVisualTone,
        translatesTitle: Bool = false,
        translatesCaption: Bool = true
    ) -> some View {
        return VStack(spacing: 2) {
            Group {
                if translatesTitle {
                    TeachingText(english: title)
                } else {
                    Text(title)
                }
            }
            .font(.caption.weight(.bold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.72)
            Group {
                if translatesCaption {
                    TeachingText(english: caption)
                } else {
                    Text(caption)
                }
            }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, compact ? 6 : 9)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, minHeight: compact ? 48 : 54)
        .background(tone.color.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(tone.color.opacity(0.18)))
    }

    private func visualIconNode(_ icon: String, tone: LearningVisualTone) -> some View {
        Image(systemName: icon)
            .font(.body.weight(.semibold))
            .foregroundStyle(tone.color)
            .frame(width: compact ? 42 : 48, height: compact ? 48 : 54)
            .background(tone.color.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            .accessibilityHidden(true)
    }

}

struct VocabularyExampleSentence: View {
    let word: VocabWord
    var target: String?
    var compact = false
    var hidesTranslationUntilRequested = false
    @State private var revealsTranslation = false

    init(word: VocabWord, target: String? = nil, compact: Bool = false, hidesTranslationUntilRequested: Bool = false) {
        self.word = word
        self.target = target
        self.compact = compact
        self.hidesTranslationUntilRequested = hidesTranslationUntilRequested
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 5 : 7) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CoachTheme.accent)
                if let target, !target.isEmpty {
                    HighlightedLearningSentence(
                        sentence: word.exampleSentence,
                        target: target,
                        tint: CoachTheme.accent
                    )
                } else {
                    Text(word.exampleSentence)
                }
                Spacer(minLength: 4)
                GrammarXRayButton(sentence: word.exampleSentence)
            }
            .font(compact ? .callout : .body.weight(.medium))
            .fixedSize(horizontal: false, vertical: true)

            if !hidesTranslationUntilRequested || revealsTranslation {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoachTheme.primary)
                        .frame(width: 12)
                    TeachingText(english: word.exampleMeaning)
                        .font(compact ? .caption : .callout)
                        .foregroundStyle(CoachTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Button {
                    withAnimation(CoachMotion.quick) { revealsTranslation = true }
                } label: {
                    TeachingLabel(english: "Check sentence meaning", systemImage: "eye")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(CoachTheme.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}

enum GrammarVisualKind: String, CaseIterable {
    case sentence = "Sentence frame"
    case table = "Pattern table"
    case caseMap = "Case roles"
    case timeline = "Time map"
    case space = "Space map"
    case transformation = "Form change"
    case scale = "Meaning scale"
    case loop = "Reflexive loop"
    case split = "Two possible paths"
    case focus = "Focus shift"
}

struct GrammarVisualNode: Hashable {
    let title: String
    let detail: String
    let tone: LearningVisualTone
    let translatesTitle: Bool
    let translatesDetail: Bool

    init(
        _ title: String,
        _ detail: String = "",
        _ tone: LearningVisualTone = .primary,
        translatesTitle: Bool? = nil,
        translatesDetail: Bool? = nil
    ) {
        self.title = title
        self.detail = detail
        self.tone = tone
        self.translatesTitle = translatesTitle
            ?? GrammarVisualLanguage.supportLanguageTitles.contains(title.lowercased())
        self.translatesDetail = translatesDetail
            ?? !GrammarVisualLanguage.germanDetails.contains(detail)
    }
}

private enum GrammarVisualLanguage {
    static let supportLanguageTitles: Set<String> = [
        "background", "context", "different subject", "event 1", "event 2",
        "future", "grammar rule", "infinitive", "main clause", "meaning",
        "not real", "now", "past action", "past reality", "present / future",
        "question", "real", "reflection", "request", "result",
        "result still happens", "same subject", "verb", "who?"
    ]

    static let germanDetails: Set<String> = [
        "Perfekt / Präteritum", "Präteritum", "Zug verpasst",
        "Ich habe Zeit.", "Ich hätte gern ...", "Wenn ich Zeit hätte ...",
        "bin / habe", "bist / hast", "ist / hat", "sind / haben",
        "seid / habt", "mein", "dein", "sein", "ihr", "unser", "euer",
        "Komm!", "Kommt!", "Kommen Sie!", "treffen", "stellen", "nehmen"
    ]
}

struct GrammarVisualSpec {
    let kind: GrammarVisualKind
    let symbol: String
    let rows: [[GrammarVisualNode]]
    let caption: String
}

private func grammarSpec(
    _ kind: GrammarVisualKind,
    _ symbol: String,
    _ rows: [[GrammarVisualNode]],
    _ caption: String
) -> GrammarVisualSpec {
    GrammarVisualSpec(kind: kind, symbol: symbol, rows: rows, caption: caption)
}

enum GrammarVisualCatalog {
    static let specs: [String: GrammarVisualSpec] = [
        "a1-alphabet-pronunciation": grammarSpec(.transformation, "character.book.closed.fill", [
            [.init("A a", "ah", .primary), .init("E e", "eh", .accent), .init("I i", "ee", .listening)],
            [.init("Ä ä", "open e", .incorrect), .init("Ö ö", "rounded e", .correct), .init("Ü ü", "rounded i", .speaking)],
            [.init("ß", "sharp s", .neutral), .init("Name", "spell it aloud", .primary)]
        ], "See the letter, hear its German sound, then use it immediately in a name or familiar word."),
        "a1-pronouns": grammarSpec(.table, "person.3.fill", [
            [.init("ich", "I", .primary), .init("du", "you", .accent), .init("er / sie / es", "he / she / it", .listening)],
            [.init("wir", "we", .correct), .init("ihr", "you all", .speaking), .init("sie / Sie", "they / formal you", .neutral)]
        ], "Choose the pronoun that matches who is doing the action."),
        "a1-sein-haben": grammarSpec(.table, "equal.circle.fill", [
            [.init("ich", "bin / habe", .primary), .init("du", "bist / hast", .accent), .init("er / sie", "ist / hat", .listening)],
            [.init("wir", "sind / haben", .correct), .init("ihr", "seid / habt", .speaking), .init("sie / Sie", "sind / haben", .neutral)]
        ], "Sein and haben change shape with the subject; learn each pair as one unit."),
        "a1-present-tense": grammarSpec(.transformation, "gearshape.2.fill", [
            [.init("lernen", "infinitive", .neutral), .init("lern-", "stem", .listening), .init("ich lerne", "stem + -e", .primary)],
            [.init("du lernst", "stem + -st", .accent), .init("er lernt", "stem + -t", .correct)]
        ], "Remove -en, then attach the ending that belongs to the subject."),
        "a1-articles-nominative": grammarSpec(.table, "square.grid.3x3.fill", [
            [.init("der", "masculine", .listening), .init("die", "feminine", .incorrect), .init("das", "neuter", .correct)],
            [.init("die", "plural", .accent), .init("Who?", "subject", .primary)]
        ], "Nominative marks the person or thing performing the action."),
        "a1-accusative": grammarSpec(.caseMap, "arrow.right.circle.fill", [
            [.init("Ich", "subject: NOM", .primary), .init("kaufe", "action", .accent), .init("den Apfel", "object: AKK", .listening)],
            [.init("der", "NOM", .listening), .init("den", "AKK", .accent)]
        ], "Only masculine der changes to den in the accusative; the direct object receives the action."),
        "a1-negation": grammarSpec(.split, "nosign", [
            [.init("kein", "before a noun", .incorrect), .init("Kaffee", "noun", .neutral)],
            [.init("nicht", "negates", .incorrect), .init("müde / kommen", "quality or action", .neutral)]
        ], "Use kein with nouns and nicht for actions, qualities, or a whole statement."),
        "a1-word-order": grammarSpec(.sentence, "rectangle.3.group.fill", [
            [.init("Heute", "position 1", .listening), .init("lerne", "verb: position 2", .accent), .init("ich", "subject", .primary), .init("Deutsch", "rest", .neutral)]
        ], "In a main clause, the conjugated verb stays in position 2 even when another element comes first."),
        "a1-questions": grammarSpec(.split, "questionmark.bubble.fill", [
            [.init("Wo", "W-word", .listening), .init("wohnst", "verb", .accent), .init("du?", "subject", .primary)],
            [.init("Wohnst", "verb first", .accent), .init("du", "subject", .primary), .init("hier?", "rest", .neutral)]
        ], "W-questions start with a question word; yes/no questions start with the verb."),
        "a1-modals": grammarSpec(.sentence, "switch.2", [
            [.init("Ich", "subject", .primary), .init("möchte", "modal: position 2", .accent), .init("Deutsch", "middle", .neutral), .init("lernen", "infinitive: end", .listening)]
        ], "The modal verb is conjugated in position 2; the second verb remains infinitive at the end."),
        "a1-possessives": grammarSpec(.table, "person.crop.circle.badge.checkmark", [
            [.init("ich", "mein", .primary), .init("du", "dein", .accent), .init("er", "sein", .listening)],
            [.init("sie", "ihr", .incorrect), .init("wir", "unser", .correct), .init("ihr", "euer", .speaking)]
        ], "The owner chooses the possessive stem; the following noun chooses its ending."),
        "a1-plurals": grammarSpec(.transformation, "rectangle.on.rectangle.fill", [
            [.init("der Tag", "singular", .listening), .init("die Tage", "plural", .accent)],
            [.init("das Buch", "singular", .correct), .init("die Bücher", "plural", .accent)]
        ], "Every plural uses die, but the noun ending and possible umlaut must be learned with the word."),
        "a1-prepositions": grammarSpec(.space, "map.fill", [
            [.init("in", "inside", .primary), .init("auf", "on top", .accent), .init("an", "at / against", .listening)],
            [.init("mit", "with", .correct), .init("nach", "to / after", .speaking), .init("von", "from / of", .neutral)]
        ], "A preposition shows the relationship between people, places, things, or time."),
        "a1-separable-verbs": grammarSpec(.sentence, "arrow.left.and.right.circle.fill", [
            [.init("Ich", "subject", .primary), .init("hole", "verb stem: position 2", .accent), .init("dich", "middle", .neutral), .init("ab", "prefix: end", .listening)]
        ], "In a main clause, the prefix separates and moves to the final position."),
        "a1-perfect-basic": grammarSpec(.timeline, "clock.arrow.circlepath", [
            [.init("past action", "completed", .listening), .init("habe / bin", "helper", .accent), .init("gemacht", "participle", .primary), .init("now", "speaking point", .correct)]
        ], "The perfect tense connects a completed past action to the present conversation."),
        "a1-adjectives-predicative": grammarSpec(.sentence, "slider.horizontal.3", [
            [.init("Die Wohnung", "subject", .primary), .init("ist", "sein", .accent), .init("klein", "base adjective", .listening)]
        ], "After sein, the adjective describes the subject and keeps its base form without an ending."),
        "a1-coordination": grammarSpec(.split, "link.circle.fill", [
            [.init("main clause", "verb in position 2", .primary), .init("und / aber / oder / denn", "equal link", .accent), .init("main clause", "verb in position 2", .listening)]
        ], "Coordinating conjunctions join equal ideas without changing normal main-clause word order."),
        "a1-time-expressions": grammarSpec(.timeline, "calendar", [
            [.init("am Montag", "day", .primary), .init("um 9 Uhr", "clock time", .accent), .init("im Juli", "month", .listening)],
            [.init("von 8", "start", .correct), .init("bis 12 Uhr", "end", .speaking)]
        ], "Match each time preposition to its scale: day, exact time, month, or range."),
        "a1-accusative-pronouns": grammarSpec(.caseMap, "person.crop.circle.badge.checkmark", [
            [.init("ich", "subject", .primary), .init("du", "subject", .primary), .init("er", "subject", .primary)],
            [.init("mich", "object", .accent), .init("dich", "object", .accent), .init("ihn", "object", .accent)]
        ], "When a person receives the action directly, change the subject pronoun into its accusative form."),
        "a1-imperative": grammarSpec(.table, "exclamationmark.bubble.fill", [
            [.init("du", "Komm!", .accent), .init("ihr", "Kommt!", .listening), .init("Sie", "Kommen Sie!", .primary)]
        ], "Choose the command form from the relationship: one familiar person, several, or formal Sie."),
        "a1-place-direction": grammarSpec(.space, "map.fill", [
            [.init("Wo?", "location: im Büro", .correct), .init("Wohin?", "destination: nach Berlin", .accent), .init("Woher?", "origin: aus Köln", .listening)]
        ], "Location, destination, and origin answer three different spatial questions."),
        "a1-formal-address": grammarSpec(.table, "person.2.fill", [
            [.init("du", "one familiar person", .primary), .init("ihr", "several familiar people", .accent)],
            [.init("Sie", "formal, capital S", .listening), .init("haben", "plural verb form", .correct)]
        ], "Choose du, ihr, or formal Sie from the relationship, then match the verb ending."),
        "a1-dative-pronouns": grammarSpec(.caseMap, "arrow.triangle.branch", [
            [.init("ich", "subject", .primary), .init("gebe", "action", .accent), .init("ihm", "receiver: DAT", .correct), .init("den Schlüssel", "thing: AKK", .listening)],
            [.init("ich", "NOM", .primary), .init("mir", "DAT", .correct), .init("du", "NOM", .primary), .init("dir", "DAT", .correct)]
        ], "The dative pronoun marks the receiver or the person affected indirectly."),
        "a1-comparative-basics": grammarSpec(.split, "chart.bar.fill", [
            [.init("schnell", "base", .neutral), .init("schneller", "+ -er", .primary), .init("als", "unequal comparison", .accent)],
            [.init("so groß", "equal", .correct), .init("wie", "same degree", .listening)]
        ], "Use -er plus als for a difference, and so...wie for equal qualities."),
        "a1-preposition-contractions": grammarSpec(.transformation, "arrow.triangle.2.circlepath", [
            [.init("an + dem", "two words", .primary), .init("am", "contracted", .accent)],
            [.init("in + dem", "two words", .primary), .init("im", "contracted", .correct)],
            [.init("zu + der", "feminine", .listening), .init("zur", "contracted", .accent)]
        ], "High-frequency prepositions and articles contract into short forms such as am, im, zum, and zur."),
        "a1-past-sein-haben": grammarSpec(.timeline, "clock.fill", [
            [.init("gestern", "past", .listening), .init("war / waren", "past state", .accent), .init("hatte / hatten", "past possession", .primary), .init("heute", "now", .correct)]
        ], "War describes a past state; hatte describes what someone possessed or experienced."),

        "a2-perfect": grammarSpec(.sentence, "text.bubble.fill", [
            [.init("Ich", "subject", .primary), .init("habe", "helper: position 2", .accent), .init("viel", "middle", .neutral), .init("gelernt", "participle: end", .listening)]
        ], "Spoken German usually frames the clause with haben or sein and the participle at the end."),
        "a2-dative": grammarSpec(.caseMap, "arrow.triangle.branch", [
            [.init("Ich", "giver: NOM", .primary), .init("gebe", "action", .accent), .init("dem Kind", "receiver: DAT", .correct), .init("das Buch", "thing: AKK", .listening)]
        ], "Dative commonly marks the receiver; accusative marks the thing being transferred."),
        "a2-two-way-prepositions": grammarSpec(.split, "location.fill", [
            [.init("Wohin?", "movement", .accent), .init("in den Park", "ACCUSATIVE", .listening)],
            [.init("Wo?", "location", .correct), .init("in dem Park", "DATIVE", .primary)]
        ], "Movement toward a destination takes accusative; a fixed location takes dative."),
        "a2-adjective-endings": grammarSpec(.table, "paintbrush.pointed.fill", [
            [.init("der gute Mann", "definite article", .listening), .init("ein guter Mann", "indefinite article", .accent)],
            [.init("die gute Frau", "feminine", .incorrect), .init("das gute Buch", "neuter", .correct)]
        ], "The article and case determine how much grammatical information the adjective ending must carry."),
        "a2-comparative": grammarSpec(.scale, "chart.bar.fill", [
            [.init("schnell", "base", .neutral), .init("schneller", "comparative", .primary), .init("am schnellsten", "superlative", .accent)]
        ], "Use -er to compare two things and am ...-sten for the highest degree."),
        "a2-reflexive": grammarSpec(.loop, "arrow.triangle.2.circlepath", [
            [.init("ich", "subject", .primary), .init("wasche", "action", .accent), .init("mich", "same person", .listening)]
        ], "The action loops back to the subject: ich-mich, du-dich, er/sie/es-sich."),
        "a2-modal-past": grammarSpec(.sentence, "clock.badge.checkmark.fill", [
            [.init("Ich", "subject", .primary), .init("musste", "past modal", .accent), .init("lange", "middle", .neutral), .init("arbeiten", "infinitive: end", .listening)]
        ], "Put the modal verb in the simple past and keep the action verb infinitive at the end."),
        "a2-relative-basic": grammarSpec(.sentence, "link.circle.fill", [
            [.init("der Mann", "reference noun", .primary), .init("der", "relative pronoun", .accent), .init("hier", "middle", .neutral), .init("wohnt", "verb: end", .listening)]
        ], "The relative pronoun points back to a noun; the conjugated verb moves to the end of the relative clause."),
        "a2-infinitive-zu": grammarSpec(.sentence, "arrow.down.to.line.compact", [
            [.init("Ich versuche", "main clause", .primary), .init("Deutsch", "middle", .neutral), .init("zu lernen", "zu + infinitive: end", .accent)]
        ], "Zu stands directly before the final infinitive, or between prefix and stem in separable verbs."),
        "a2-indirect-questions": grammarSpec(.sentence, "questionmark.bubble.fill", [
            [.init("Ich weiß nicht", "intro", .primary), .init("wann", "question word", .accent), .init("er", "subject", .neutral), .init("kommt", "verb: end", .listening)]
        ], "An indirect question becomes a subordinate clause, so its verb moves to the end."),
        "a2-preterite": grammarSpec(.timeline, "clock.fill", [
            [.init("damals", "past", .neutral), .init("war", "sein", .listening), .init("hatte", "haben", .accent), .init("heute", "now", .correct)]
        ], "War and hatte are the common simple-past forms used in both speech and writing."),
        "a2-verbs-prepositions": grammarSpec(.caseMap, "link", [
            [.init("warten", "verb", .primary), .init("auf", "fixed preposition", .accent), .init("den Bus", "ACCUSATIVE", .listening)],
            [.init("helfen", "verb", .primary), .init("bei", "fixed preposition", .accent), .init("der Arbeit", "DATIVE", .correct)]
        ], "Learn each verb together with its fixed preposition and required case."),
        "a2-purpose": grammarSpec(.split, "target", [
            [.init("same subject", "one actor", .primary), .init("um ... zu", "purpose", .accent), .init("infinitive", "end", .listening)],
            [.init("different subject", "two actors", .correct), .init("damit", "purpose clause", .accent), .init("verb", "end", .listening)]
        ], "Use um ... zu when both actions share a subject; use damit when the subjects differ."),
        "a2-subordinate": grammarSpec(.sentence, "arrow.turn.down.right", [
            [.init("weil / dass / wenn", "connector", .accent), .init("ich", "subject", .primary), .init("heute", "middle", .neutral), .init("lerne", "verb: end", .listening)]
        ], "A subordinating connector sends the conjugated verb to the end of its clause."),
        "a2-participle-formation": grammarSpec(.transformation, "wand.and.stars", [
            [.init("machen", "regular", .primary), .init("gemacht", "ge- + stem + -t", .accent)],
            [.init("bezahlen", "inseparable", .primary), .init("bezahlt", "no ge-", .listening), .init("ausfüllen", "separable", .primary), .init("ausgefüllt", "prefix + ge-", .correct)]
        ], "The verb prefix and ending tell you where ge- belongs, or whether it disappears."),
        "a2-causal-connectors": grammarSpec(.split, "arrow.triangle.branch", [
            [.init("weil", "reason", .accent), .init("Verb am Ende", "subordinate", .listening)],
            [.init("denn", "reason", .primary), .init("Verb position 2", "main clause", .correct), .init("deshalb", "result", .accent), .init("Verb follows", "inversion", .speaking)]
        ], "Reason and result words express similar logic but create different word-order patterns."),
        "a2-object-pronouns": grammarSpec(.caseMap, "arrow.triangle.branch", [
            [.init("ich", "giver: NOM", .primary), .init("es", "thing: AKK", .accent), .init("ihm", "receiver: DAT", .correct)]
        ], "With two pronouns, the direct object usually comes before the dative recipient."),
        "a2-indefinite-pronouns": grammarSpec(.table, "person.3.fill", [
            [.init("man", "people in general", .primary), .init("jemand", "one person", .accent), .init("niemand", "no person", .incorrect)],
            [.init("etwas", "some thing", .correct), .init("nichts", "no thing", .neutral)]
        ], "Indefinite pronouns name people or things without identifying them precisely."),
        "a2-temporal-clauses": grammarSpec(.timeline, "clock.arrow.2.circlepath", [
            [.init("als", "one past event", .listening), .init("wenn", "repeated / present", .primary), .init("bevor", "earlier", .accent), .init("nachdem", "already completed", .correct)]
        ], "Choose a time connector by whether the event is unique, repeated, earlier, or already complete."),
        "a2-pronominal-adverbs": grammarSpec(.transformation, "arrow.triangle.2.circlepath", [
            [.init("auf + Sache", "preposition + thing", .primary), .init("darauf", "reference", .accent)],
            [.init("wo + auf", "question", .listening), .init("worauf?", "about a thing", .correct), .init("auf wen?", "about a person", .speaking)]
        ], "Da- compounds point back to things; wo- compounds ask about things; people keep the pronoun."),
        "a2-time-manner-place": grammarSpec(.sentence, "rectangle.3.group.fill", [
            [.init("morgen", "TIME", .listening), .init("wegen des Kurses", "REASON", .accent), .init("mit dem Bus", "MANNER", .correct), .init("zur Arbeit", "PLACE", .primary)]
        ], "TeKaMoLo is a dependable neutral order: time, reason, manner, then place."),
        "a2-double-object-order": grammarSpec(.caseMap, "arrow.triangle.branch", [
            [.init("dem Kunden", "DAT noun", .correct), .init("das Formular", "AKK noun", .listening)],
            [.init("es", "AKK pronoun first", .accent), .init("ihm", "DAT pronoun second", .correct)]
        ], "Noun objects usually place dative first; two pronouns usually place accusative first."),
        "a2-reflexive-dative": grammarSpec(.loop, "arrow.triangle.2.circlepath", [
            [.init("ich", "subject", .primary), .init("wasche", "action", .accent), .init("mir", "DAT: same person", .correct), .init("die Hände", "AKK object", .listening)]
        ], "When a body part or belonging is the direct object, the reflexive person moves into dative."),
        "a2-n-declension-basic": grammarSpec(.transformation, "textformat.abc.dottedunderline", [
            [.init("der Kunde", "NOM singular", .primary), .init("den Kunden", "AKK + -n", .accent)],
            [.init("der Kollege", "NOM singular", .primary), .init("mit dem Kollegen", "DAT + -n", .correct)]
        ], "Weak masculine nouns add -n or -en outside the nominative singular."),
        "a2-werden-changes": grammarSpec(.transformation, "arrow.forward.circle.fill", [
            [.init("kalt", "new quality", .listening), .init("es wird kalt", "change", .accent)],
            [.init("Ärztin", "new role", .correct), .init("sie wird Ärztin", "becoming", .primary)]
        ], "Werden links the subject to a new quality, role, or state without adding sein."),

        "b1-past-narrative": grammarSpec(.timeline, "book.pages.fill", [
            [.init("background", "Präteritum", .neutral), .init("event 1", "Perfekt / Präteritum", .listening), .init("event 2", "sequence", .accent), .init("reflection", "now", .correct)]
        ], "Narratives combine background description with a clear sequence of completed events."),
        "b1-relative": grammarSpec(.caseMap, "point.3.connected.trianglepath.dotted", [
            [.init("der", "subject: NOM", .primary), .init("den", "object: AKK", .accent), .init("dem", "receiver: DAT", .correct), .init("dessen / deren", "possession: GEN", .listening)]
        ], "The relative pronoun's gender comes from its reference noun; its case comes from its role inside the relative clause."),
        "b1-passive": grammarSpec(.focus, "arrow.triangle.swap", [
            [.init("Man repariert", "agent + action", .neutral), .init("die Straße", "object", .listening)],
            [.init("Die Straße", "new focus", .primary), .init("wird repariert", "werden + participle", .accent)]
        ], "Passive moves attention from the agent to the process or affected object."),
        "b1-genitive": grammarSpec(.caseMap, "person.crop.circle.badge.checkmark", [
            [.init("das Auto", "owned thing", .primary), .init("des Mannes", "owner: masculine", .listening)],
            [.init("die Idee", "owned thing", .primary), .init("der Frau", "owner: feminine", .incorrect)]
        ], "Genitive marks formal possession; masculine and neuter nouns often add -(e)s."),
        "b1-adjective-endings": grammarSpec(.table, "paintbrush.fill", [
            [.init("guter Wein", "masc. NOM", .listening), .init("guten Wein", "masc. AKK", .accent)],
            [.init("mit gutem Wein", "masc. DAT", .correct), .init("gute Weine", "plural NOM/AKK", .speaking)]
        ], "Without an article, the adjective ending carries the gender, number, and case signal."),
        "b1-n-declension": grammarSpec(.transformation, "textformat.abc.dottedunderline", [
            [.init("der Student", "NOM singular", .primary), .init("den Studenten", "AKK", .accent)],
            [.init("dem Studenten", "DAT", .correct), .init("des Studenten", "GEN", .listening)]
        ], "Most masculine n-nouns add -n or -en in every singular case except nominative."),
        "b1-participles-adjectives": grammarSpec(.transformation, "wand.and.stars", [
            [.init("lachen", "verb", .primary), .init("lachend", "present participle", .accent), .init("das lachende Kind", "adjective", .listening)],
            [.init("schließen", "verb", .primary), .init("geschlossen", "past participle", .correct), .init("die geschlossene Tür", "adjective", .listening)]
        ], "A participle can move before a noun and then takes a normal adjective ending."),
        "b1-nominalization": grammarSpec(.transformation, "textformat.size", [
            [.init("lernen", "verb", .primary), .init("das Lernen", "noun", .accent)],
            [.init("neu", "adjective", .listening), .init("das Neue", "noun", .correct)]
        ], "Nominalized verbs and adjectives become capitalized nouns and often use das."),
        "b1-connectors": grammarSpec(.split, "link.badge.plus", [
            [.init("nicht nur", "adds first point", .primary), .init("sondern auch", "adds second point", .accent)],
            [.init("zwar", "admits a point", .listening), .init("aber", "contrasts it", .incorrect)]
        ], "Paired connectors show the logical relationship between two balanced ideas."),
        "b1-indirect-speech": grammarSpec(.transformation, "quote.bubble.fill", [
            [.init("\"Ich bin krank.\"", "direct quote", .listening), .init("Er sagt", "reporting frame", .primary), .init("er sei krank", "reported speech", .accent)]
        ], "Reported speech shifts the speaker's words into a reporting frame, often with Konjunktiv I."),
        "b1-future": grammarSpec(.timeline, "forward.fill", [
            [.init("jetzt", "present", .correct), .init("werde", "conjugated helper", .accent), .init("morgen arbeiten", "infinitive at end", .listening), .init("future", "plan / assumption", .primary)]
        ], "Werden in position 2 plus an infinitive at the end expresses future plans or assumptions."),
        "b1-concessive": grammarSpec(.split, "arrow.left.arrow.right", [
            [.init("Obwohl", "unexpected cause", .accent), .init("es regnet", "verb at end", .listening), .init("gehen wir", "result", .primary)],
            [.init("Es regnet", "statement", .listening), .init("trotzdem", "contrast", .accent), .init("gehen wir", "verb position 2", .primary)]
        ], "Obwohl introduces a verb-final clause; trotzdem is an adverb and keeps main-clause verb order."),
        "b1-alternatives": grammarSpec(.split, "arrow.triangle.2.circlepath", [
            [.init("kann gemacht werden", "modal passive", .primary)],
            [.init("ist zu machen", "sein + zu", .accent), .init("lässt sich machen", "lassen + sich", .correct)]
        ], "These structures describe possibility or necessity while keeping the agent unimportant."),
        "b1-konjunktiv-ii": grammarSpec(.split, "arrow.triangle.branch", [
            [.init("real", "Ich habe Zeit.", .correct), .init("request", "Ich hätte gern ...", .primary)],
            [.init("not real", "Wenn ich Zeit hätte ...", .accent), .init("result", "würde ich kommen", .listening)]
        ], "Konjunktiv II creates polite distance or marks a situation as imagined rather than real."),
        "b1-plusquamperfekt": grammarSpec(.timeline, "clock.arrow.circlepath", [
            [.init("hatte / war", "past helper", .accent), .init("gemacht", "earlier event", .listening), .init("kam / ging", "later past event", .primary)]
        ], "Past perfect moves one completed event behind another event in a past narrative."),
        "b1-temporal-connectors": grammarSpec(.timeline, "clock.fill", [
            [.init("bevor", "event A first", .accent), .init("während", "at the same time", .listening), .init("nachdem", "event A completed", .correct), .init("seitdem", "continues until now", .primary)]
        ], "Advanced time connectors show exact sequence, overlap, and duration across clauses."),
        "b1-conditionals": grammarSpec(.split, "arrow.triangle.branch", [
            [.init("falls / sofern", "real possibility", .correct), .init("present / future", "likely result", .primary)],
            [.init("wenn ... hätte", "imagined condition", .accent), .init("würde ...", "hypothetical result", .listening)]
        ], "Real conditions use normal tense; imagined conditions mark both sides with Konjunktiv II."),
        "b1-extended-infinitives": grammarSpec(.split, "arrow.down.to.line.compact", [
            [.init("ohne ... zu", "missing action", .incorrect), .init("statt ... zu", "alternative action", .accent), .init("um ... zu", "purpose", .correct)]
        ], "These infinitive groups compress two actions that share the same subject."),
        "b1-collocations": grammarSpec(.table, "puzzlepiece.extension.fill", [
            [.init("Entscheidung", "treffen", .primary), .init("Antrag", "stellen", .accent), .init("Rücksicht", "nehmen", .correct)]
        ], "Store formal noun-verb partnerships as one lexical unit instead of translating each word separately."),
        "b1-result-manner": grammarSpec(.split, "arrow.triangle.branch", [
            [.init("indem", "method: how?", .primary), .init("dadurch, dass", "method", .correct)],
            [.init("sodass", "result", .accent), .init("so ... dass", "degree + result", .listening)]
        ], "Indem explains the method; sodass explains the consequence produced by the first clause."),
        "b1-passive-modal-verbs": grammarSpec(.focus, "arrow.triangle.swap", [
            [.init("Man muss", "agent-focused", .neutral), .init("den Antrag prüfen", "active", .listening)],
            [.init("Der Antrag", "new focus", .primary), .init("muss geprüft werden", "modal passive", .accent)]
        ], "The conjugated modal frames the clause; past participle plus werden closes the passive."),
        "b1-relative-wo-was": grammarSpec(.split, "link.circle.fill", [
            [.init("der Ort", "place", .primary), .init("wo ...", "everyday reference", .accent)],
            [.init("alles / nichts / das", "broad reference", .correct), .init("was ...", "relative clause", .listening)]
        ], "Wo can connect to a place; was connects to broad words or comments on a whole statement."),
        "b1-modal-particles": grammarSpec(.table, "quote.bubble.fill", [
            [.init("doch", "shared knowledge", .primary), .init("mal", "soft request", .accent)],
            [.init("eben", "acceptance", .listening), .init("wohl", "probability", .correct)]
        ], "Modal particles color the speaker's attitude; their force comes from context and stress."),
        "b1-concessive-alternatives": grammarSpec(.split, "arrow.left.arrow.right", [
            [.init("auch wenn", "real obstacle", .primary), .init("result still happens", "unchanged", .correct)],
            [.init("selbst wenn", "extreme possibility", .accent), .init("trotz + noun", "compressed contrast", .listening)]
        ], "Choose a concessive link by whether the obstacle is real, extreme, or expressed as a noun."),
        "b1-konjunktiv-past": grammarSpec(.timeline, "clock.arrow.circlepath", [
            [.init("past reality", "Zug verpasst", .incorrect), .init("wäre früher gefahren", "imagined condition", .accent), .init("hätte erreicht", "imagined result", .correct)]
        ], "Hätte or wäre plus a participle rewrites a past event that can no longer be changed.")
    ]

    static var supportedTopicIDs: Set<String> { Set(specs.keys) }

    static func spec(for topicID: String) -> GrammarVisualSpec {
        specs[topicID] ?? grammarSpec(
            .sentence,
            "text.book.closed.fill",
            [[.init("context", "start", .primary), .init("grammar rule", "pattern", .accent), .init("meaning", "result", .listening)]],
            "Follow the pattern from left to right, then compare it with the lesson examples."
        )
    }
}

struct GrammarVisualExplanation: View {
    let topic: GrammarTopic
    var compact = false
    @State private var usesFormalContext = false
    @State private var hasRevealedPattern = false

    private var spec: GrammarVisualSpec { GrammarVisualCatalog.spec(for: topic.id) }

    private var caseCues: [GermanGrammarCase] {
        let text = spec.rows
            .flatMap { $0 }
            .map { "\($0.title) \($0.detail)" }
            .joined(separator: " ") + " \(topic.id) \(topic.title)"
        return GermanGrammarCase.allCases.filter { grammarCase in
            switch grammarCase {
            case .nominative: text.localizedCaseInsensitiveContains("NOM") || text.localizedCaseInsensitiveContains("nominative")
            case .accusative: text.localizedCaseInsensitiveContains("AKK") || text.localizedCaseInsensitiveContains("accusative")
            case .dative: text.localizedCaseInsensitiveContains("DAT") || text.localizedCaseInsensitiveContains("dative")
            case .genitive: text.localizedCaseInsensitiveContains("GEN") || text.localizedCaseInsensitiveContains("genitive")
            }
        }
    }

    private var visualTint: Color {
        caseCues.first?.color ?? CoachTheme.accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 9 : 12) {
            HStack(spacing: 9) {
                Image(systemName: spec.symbol)
                    .font(.body.weight(.bold))
                    .foregroundStyle(visualTint)
                    .frame(width: 34, height: 34)
                    .background(visualTint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                TeachingText(english: spec.kind.rawValue)
                    .font(.callout.weight(.semibold))
                Spacer()
                TeachingText(english: "VISUAL RULE")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CoachTheme.primary)
            }

            if !caseCues.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(caseCues) { grammarCase in
                            GrammarCaseBadge(grammarCase: grammarCase)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }

            if topic.id.contains("formal-address") {
                FormalityStyleToggle(isFormal: $usesFormalContext)
            }

            if !compact {
                GrammarMemoryScene(topicID: topic.id)
                    .overlay(alignment: .bottomLeading) {
                        TeachingLabel(english: "See the pattern", systemImage: "eye.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.42), in: Capsule())
                            .padding(8)
                    }
            }

            diagram

            TeachingText(english: spec.caption)
                .font(compact ? .caption : .callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Visual rule for \(topic.title). \(spec.caption)")
        .onAppear {
            guard !compact else { return }
            withAnimation(CoachMotion.standard.delay(0.08)) { hasRevealedPattern = true }
        }
    }

    @ViewBuilder private var diagram: some View {
        switch spec.kind {
        case .table, .space:
            if spec.kind == .table {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: compact ? 82 : 104), spacing: 7)],
                    spacing: 7
                ) {
                    ForEach(Array(spec.rows.flatMap { $0 }.enumerated()), id: \.offset) { index, node in
                        grammarNode(node, dense: true)
                            .coachReveal(index: index)
                    }
                }
            } else {
                VStack(spacing: 7) {
                    ForEach(spec.rows.indices, id: \.self) { index in
                        nodeRow(spec.rows[index], arrows: false)
                    }
                }
            }
        case .timeline:
            VStack(spacing: 7) {
                ForEach(spec.rows.indices, id: \.self) { index in
                    ZStack {
                        Capsule()
                            .fill(CoachTheme.accent.opacity(0.22))
                            .frame(height: 3)
                            .padding(.horizontal, 20)
                        nodeRow(spec.rows[index], arrows: false)
                    }
                }
            }
        case .scale:
            HStack(alignment: .bottom, spacing: 7) {
                ForEach(Array((spec.rows.first ?? []).enumerated()), id: \.offset) { index, node in
                    grammarNode(node)
                        .scaleEffect(0.88 + Double(index) * 0.06, anchor: .bottom)
                    if index < (spec.rows.first?.count ?? 0) - 1 {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.accent)
                    }
                }
            }
        case .loop:
            if let row = spec.rows.first {
                HStack(spacing: 7) {
                    ForEach(Array(row.enumerated()), id: \.offset) { index, node in
                        grammarNode(node)
                        if index < row.count - 1 {
                            Image(systemName: index == row.count - 2 ? "arrow.uturn.backward.circle.fill" : "arrow.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(index == row.count - 2 ? CoachTheme.accent : Color.secondary)
                        }
                    }
                }
            }
        case .split, .focus:
            VStack(spacing: 7) {
                ForEach(spec.rows.indices, id: \.self) { index in
                    if index > 0 {
                        HStack {
                            Rectangle().fill(.primary.opacity(0.09)).frame(height: 1)
                            TeachingText(english: spec.kind == .focus ? "BECOMES" : "OR")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(CoachTheme.accent)
                            Rectangle().fill(.primary.opacity(0.09)).frame(height: 1)
                        }
                    }
                    nodeRow(spec.rows[index], arrows: true)
                }
            }
        case .sentence, .caseMap, .transformation:
            VStack(spacing: 7) {
                ForEach(spec.rows.indices, id: \.self) { index in
                    nodeRow(spec.rows[index], arrows: true)
                }
            }
        }
    }

    private func nodeRow(_ nodes: [GrammarVisualNode], arrows: Bool) -> some View {
        HStack(spacing: compact ? 5 : 7) {
            ForEach(Array(nodes.enumerated()), id: \.offset) { index, node in
                grammarNode(node, dense: nodes.count >= 4)
                if arrows && index < nodes.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func grammarNode(_ node: GrammarVisualNode, dense: Bool = false) -> some View {
        let grammarCase = GermanGrammarCase.inferred(from: "\(node.title) \(node.detail)")
        let nodeColor = grammarCase?.color ?? node.tone.color

        return VStack(spacing: 2) {
            if ["der", "die", "das"].contains(node.title.lowercased()) {
                GermanArticleChip(article: node.title)
            } else {
                Group {
                    if node.translatesTitle {
                        TeachingText(english: node.title)
                    } else {
                        Text(node.title)
                    }
                }
                    .font((compact || dense ? Font.caption : Font.callout).weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.62)
                    .allowsTightening(true)
            }
            if !node.detail.isEmpty {
                Group {
                    if node.translatesDetail {
                        TeachingText(english: node.detail)
                    } else {
                        Text(node.detail)
                    }
                }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
            }
        }
        .padding(.horizontal, compact ? 4 : 7)
        .padding(.vertical, compact ? 6 : 8)
        .frame(maxWidth: .infinity, minHeight: compact ? 48 : 58)
        .background(
            RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                .fill(CoachTheme.elevatedSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                        .fill(nodeColor.opacity(0.12))
                }
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(nodeColor.opacity(0.24)))
        .opacity(formalityOpacity(for: node))
        .scaleEffect(hasRevealedPattern || compact ? 1 : 0.9)
        .opacity(hasRevealedPattern || compact ? formalityOpacity(for: node) : 0.12)
        .animation(CoachMotion.quick, value: usesFormalContext)
        .animation(CoachMotion.standard, value: hasRevealedPattern)
        .accessibilityElement(children: .combine)
        .teachingAccessibilityHint(grammarCase?.accessibilityDescription ?? "Grammar pattern slot")
    }

    private func formalityOpacity(for node: GrammarVisualNode) -> Double {
        guard topic.id.contains("formal-address") else { return 1 }
        let title = node.title.lowercased()
        if usesFormalContext {
            return title == "du" || title == "ihr" ? 0.38 : 1
        }
        return title == "sie" ? 0.38 : 1
    }
}

enum GermanAlphabetGroup: String, CaseIterable, Identifiable {
    case aToI
    case jToR
    case sToZ
    case special

    var id: String { rawValue }

    var title: String {
        switch self {
        case .aToI: "A–I"
        case .jToR: "J–R"
        case .sToZ: "S–Z"
        case .special: "Ä Ö Ü ß"
        }
    }
}

struct GermanAlphabetEntry: Identifiable, Hashable {
    let id: String
    let display: String
    let spokenLetterName: String
    let letterNameIPA: String
    let example: String
    let exampleIPA: String
    let soundTip: String
    let group: GermanAlphabetGroup
}

enum GermanAlphabetCatalog {
    static let entries: [GermanAlphabetEntry] = [
        entry("A", "A · a", "A", "/aː/", "Apfel", "/ˈapfəl/", "A is often a clear /a/ as in Apfel.", .aToI),
        entry("B", "B · b", "Be", "/beː/", "Ball", "/bal/", "B is /b/ at the start of Ball.", .aToI),
        entry("C", "C · c", "Ce", "/tseː/", "Computer", "/kɔmˈpjuːtɐ/", "C can sound /k/ in words such as Computer and /ts/ in some German words.", .aToI),
        entry("D", "D · d", "De", "/deː/", "Deutsch", "/dɔʏtʃ/", "D begins Deutsch with a clear /d/ sound.", .aToI),
        entry("E", "E · e", "E", "/eː/", "Essen", "/ˈɛsn̩/", "E can be short /ɛ/ as in Essen or long /eː/ as in See.", .aToI),
        entry("F", "F · f", "Eff", "/ɛf/", "Fisch", "/fɪʃ/", "F consistently makes the /f/ sound.", .aToI),
        entry("G", "G · g", "Ge", "/ɡeː/", "gut", "/ɡuːt/", "G begins gut with /ɡ/; its sound can change at the end of a word.", .aToI),
        entry("H", "H · h", "Ha", "/haː/", "Haus", "/haʊs/", "H is heard as a breathy /h/ at the start of Haus.", .aToI),
        entry("I", "I · i", "I", "/iː/", "ich", "/ɪç/", "I can be short /ɪ/ as in ich or long /iː/ as in Kino.", .aToI),

        entry("J", "J · j", "Jott", "/jɔt/", "ja", "/jaː/", "German J sounds like English y in yes.", .jToR),
        entry("K", "K · k", "Ka", "/kaː/", "Kind", "/kɪnt/", "K makes a clean /k/ sound.", .jToR),
        entry("L", "L · l", "Ell", "/ɛl/", "Lampe", "/ˈlampə/", "L is a light /l/ sound with the tongue near the upper teeth.", .jToR),
        entry("M", "M · m", "Emm", "/ɛm/", "Mutter", "/ˈmʊtɐ/", "M is made with closed lips, as in Mutter.", .jToR),
        entry("N", "N · n", "Enn", "/ɛn/", "Name", "/ˈnaːmə/", "N is the clear /n/ sound in Name.", .jToR),
        entry("O", "O · o", "O", "/oː/", "Oma", "/ˈoːmaː/", "O can be long /oː/ as in Oma or short /ɔ/ as in Post.", .jToR),
        entry("P", "P · p", "Pe", "/peː/", "Post", "/pɔst/", "P begins Post with a small burst of air.", .jToR),
        entry("Q", "Q · q", "Qu", "/kuː/", "Quelle", "/ˈkvɛlə/", "Q normally appears as qu and the pair sounds /kv/.", .jToR),
        entry("R", "R · r", "Err", "/ɛʁ/", "rot", "/ʁoːt/", "German R varies by region; both a throat R and a rolled R are understood.", .jToR),

        entry("S", "S · s", "Ess", "/ɛs/", "Sonne", "/ˈzɔnə/", "S often sounds /z/ before a vowel at the start of a word.", .sToZ),
        entry("T", "T · t", "Te", "/teː/", "Tag", "/taːk/", "T is a crisp /t/ sound as in Tag.", .sToZ),
        entry("U", "U · u", "U", "/uː/", "und", "/ʊnt/", "U can be short /ʊ/ as in und or long /uː/ as in gut.", .sToZ),
        entry("V", "V · v", "Vau", "/faʊ/", "Vater", "/ˈfaːtɐ/", "V usually sounds /f/ in native German words such as Vater.", .sToZ),
        entry("W", "W · w", "We", "/veː/", "Wasser", "/ˈvasɐ/", "German W sounds /v/, not like English W.", .sToZ),
        entry("X", "X · x", "Ix", "/ɪks/", "Taxi", "/ˈtaksi/", "X normally represents the two sounds /ks/.", .sToZ),
        entry("Y", "Y · y", "Ypsilon", "/ˈʏpsilɔn/", "Typ", "/tyːp/", "Y often has the rounded Ü sound in words such as Typ.", .sToZ),
        entry("Z", "Z · z", "Zett", "/tsɛt/", "Zeit", "/tsaɪt/", "German Z always begins with the two-part /ts/ sound.", .sToZ),

        entry("Ä", "Ä · ä", "Ä", "/ɛː/", "Äpfel", "/ˈɛpfəl/", "Ä is an open front vowel, close to the e sound in English bed.", .special),
        entry("Ö", "Ö · ö", "Ö", "/øː/", "Öl", "/øːl/", "For Ö, shape the tongue for E and round the lips.", .special),
        entry("Ü", "Ü · ü", "Ü", "/yː/", "Tür", "/tyːɐ̯/", "For Ü, shape the tongue for I and round the lips.", .special),
        entry("ß", "ß", "Eszett", "/ɛsˈtsɛt/", "Straße", "/ˈʃtʁaːsə/", "ß is called Eszett or sharp S and represents an unvoiced /s/ sound.", .special)
    ]

    static func entries(in group: GermanAlphabetGroup) -> [GermanAlphabetEntry] {
        entries.filter { $0.group == group }
    }

    private static func entry(
        _ id: String,
        _ display: String,
        _ spokenLetterName: String,
        _ letterNameIPA: String,
        _ example: String,
        _ exampleIPA: String,
        _ soundTip: String,
        _ group: GermanAlphabetGroup
    ) -> GermanAlphabetEntry {
        GermanAlphabetEntry(
            id: id,
            display: display,
            spokenLetterName: spokenLetterName,
            letterNameIPA: letterNameIPA,
            example: example,
            exampleIPA: exampleIPA,
            soundTip: soundTip,
            group: group
        )
    }
}

struct GermanAlphabetLessonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("germanAlphabet.practiced.v1") private var practicedStorage = ""
    @State private var selectedGroup = GermanAlphabetGroup.aToI
    @State private var selectedEntryID = "A"

    private var groupEntries: [GermanAlphabetEntry] {
        GermanAlphabetCatalog.entries(in: selectedGroup)
    }

    private var selectedEntry: GermanAlphabetEntry {
        groupEntries.first { $0.id == selectedEntryID }
            ?? groupEntries.first
            ?? GermanAlphabetCatalog.entries[0]
    }

    private var practicedIDs: Set<String> {
        Set(practicedStorage.split(separator: "|").map(String.init))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CoachCard(tint: CoachTheme.listening) {
                HStack(alignment: .top, spacing: 12) {
                    CoachMascot(mood: .welcome, size: 54)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 5) {
                        TeachingText(english: "German alphabet and sounds")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        TeachingText(
                            english: "First hear the letter name used for spelling. Then hear the example word to learn the sound in real German."
                        )
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LessonProgressBar(
                    progress: Double(practicedIDs.count)
                        / Double(max(GermanAlphabetCatalog.entries.count, 1))
                )
                TeachingText(
                    english: "\(practicedIDs.count) of \(GermanAlphabetCatalog.entries.count) letter sounds heard"
                )
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(CoachTheme.listening)
            }

            Picker(selection: $selectedGroup) {
                ForEach(GermanAlphabetGroup.allCases) { group in
                    Text(group.title).tag(group)
                }
            } label: {
                TeachingText(english: "Alphabet group")
            }
            .pickerStyle(.segmented)
            .teachingAccessibilityLabel("Alphabet letter group")

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: "Tap a letter to hear its German name")
                        .font(.callout.weight(.semibold))
                    TeachingText(english: "A checkmark remembers the sounds you have practiced.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Button {
                    playGroup()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
                .teachingAccessibilityLabel("Play all letter names in this group")
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 9),
                    GridItem(.flexible(), spacing: 9),
                    GridItem(.flexible(), spacing: 9)
                ],
                spacing: 9
            ) {
                ForEach(groupEntries) { entry in
                    alphabetTile(entry)
                }
            }

            alphabetDetail(selectedEntry)
                .id(selectedEntry.id)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.98)))
        }
        .onChange(of: selectedGroup) { _, group in
            guard let first = GermanAlphabetCatalog.entries(in: group).first else { return }
            if reduceMotion {
                selectedEntryID = first.id
            } else {
                withAnimation(CoachMotion.quick) {
                    selectedEntryID = first.id
                }
            }
            CoachFeedback.selection()
        }
        .animation(reduceMotion ? nil : CoachMotion.quick, value: selectedEntryID)
    }

    private func alphabetTile(_ entry: GermanAlphabetEntry) -> some View {
        let isSelected = selectedEntryID == entry.id
        let isPracticed = practicedIDs.contains(entry.id)
        return Button {
            selectedEntryID = entry.id
            playLetter(entry)
        } label: {
            VStack(spacing: 5) {
                HStack(alignment: .top, spacing: 2) {
                    Spacer(minLength: 0)
                    Text(entry.display)
                        .font(.system(.title3, design: .rounded, weight: .heavy))
                        .foregroundStyle(isSelected ? CoachTheme.listening : Color.primary)
                        .minimumScaleFactor(0.76)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: isPracticed ? "checkmark.circle.fill" : "speaker.wave.1")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(isPracticed ? CoachTheme.correct : CoachTheme.listening)
                }
                Text(entry.letterNameIPA)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(entry.example)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoachTheme.ink)
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(
                isSelected ? CoachTheme.listening.opacity(0.13) : CoachTheme.elevatedSurface,
                in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                    .stroke(CoachTheme.listening.opacity(isSelected ? 0.52 : 0.16), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel(
            "\(entry.display), letter name \(entry.spokenLetterName), example \(entry.example)",
            protectedGerman: [entry.display, entry.spokenLetterName, entry.example]
        )
        .teachingAccessibilityValue(isPracticed ? "Practiced" : "Not practiced")
        .teachingAccessibilityHint("Plays the German letter name and opens its sound explanation")
    }

    private func alphabetDetail(_ entry: GermanAlphabetEntry) -> some View {
        CoachCard(tint: CoachTheme.reward) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 13) {
                    Text(entry.display)
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(CoachTheme.listening)
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                    VStack(alignment: .leading, spacing: 4) {
                        TeachingText(english: "Letter name")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Text(entry.spokenLetterName)
                                .font(.title3.weight(.bold))
                            Text(entry.letterNameIPA)
                                .font(.callout.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                    Button {
                        playLetter(entry)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
                    .teachingAccessibilityLabel(
                        "Hear the letter \(entry.id)",
                        protectedGerman: [entry.id]
                    )
                }

                Divider()

                HStack(alignment: .center, spacing: 11) {
                    VStack(alignment: .leading, spacing: 4) {
                        TeachingText(english: "Sound in a real word")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(entry.example)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Text(entry.exampleIPA)
                            .font(.callout.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    Button {
                        GermanSpeechService.shared.speak(entry.example, style: .word)
                        CoachFeedback.selection()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.accent))
                    .teachingAccessibilityLabel(
                        "Hear the example word \(entry.example)",
                        protectedGerman: [entry.example]
                    )
                }

                HStack(alignment: .top, spacing: 9) {
                    Image(systemName: "mouth.fill")
                        .foregroundStyle(CoachTheme.reward)
                    TeachingText(english: entry.soundTip)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func playLetter(_ entry: GermanAlphabetEntry) {
        GermanSpeechService.shared.speak(entry.spokenLetterName, style: .word)
        var updated = practicedIDs
        updated.insert(entry.id)
        practicedStorage = updated.sorted().joined(separator: "|")
        CoachFeedback.selection()
    }

    private func playGroup() {
        let speech = groupEntries
            .map { "\($0.spokenLetterName), wie \($0.example)" }
            .joined(separator: ". ")
        GermanSpeechService.shared.speak(speech, style: .model)
        var updated = practicedIDs
        updated.formUnion(groupEntries.map(\.id))
        practicedStorage = updated.sorted().joined(separator: "|")
        CoachFeedback.selection()
    }
}

struct SentenceBuilderGameRound: Identifiable, Hashable {
    let id: String
    let topicID: String
    let example: ExampleSentence
}

enum SentenceBuilderGameFactory {
    static let defaultRoundCount = 8

    static func makeRounds(
        topics: [GrammarTopic],
        level: CEFRLevel,
        startingTopicID: String? = nil,
        count: Int = defaultRoundCount
    ) -> [SentenceBuilderGameRound] {
        guard count > 0 else { return [] }

        var seenSentences: Set<String> = []
        let levelTopics = topics
            .filter { $0.cefrLevel == level }
            .sorted { lhs, rhs in
                lhs.order == rhs.order ? lhs.title < rhs.title : lhs.order < rhs.order
            }
        let prioritizedTopics: [GrammarTopic]
        if let startingTopicID,
           let focusedTopic = levelTopics.first(where: { $0.id == startingTopicID }) {
            prioritizedTopics = [focusedTopic] + levelTopics.filter { $0.id != startingTopicID }
        } else {
            prioritizedTopics = levelTopics
        }

        let candidates = prioritizedTopics
            .flatMap { topic in
                topic.examples.enumerated().compactMap { index, example -> SentenceBuilderGameRound? in
                    let normalizedSentence = GrammarStructureReasoner.normalized(example.german)
                    guard !normalizedSentence.isEmpty, seenSentences.insert(normalizedSentence).inserted else {
                        return nil
                    }
                    return SentenceBuilderGameRound(
                        id: "\(topic.id)-\(index)-\(normalizedSentence)",
                        topicID: topic.id,
                        example: example
                    )
                }
            }

        guard !candidates.isEmpty else { return [] }

        var rounds: [SentenceBuilderGameRound] = []
        if let startingTopicID,
           let focusedRound = candidates.filter({ $0.topicID == startingTopicID }).randomElement() {
            rounds.append(focusedRound)
        }

        let selectedIDs = Set(rounds.map(\.id))
        rounds.append(
            contentsOf: candidates
                .filter { !selectedIDs.contains($0.id) }
                .shuffled()
                .prefix(max(0, count - rounds.count))
        )
        return rounds
    }
}

struct SentenceBuilderGameView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GrammarTopic.order) private var allTopics: [GrammarTopic]
    @AppStorage private var bestScore: Int
    @AppStorage private var completedSessions: Int

    let level: CEFRLevel
    let startingTopicID: String?

    @State private var rounds: [SentenceBuilderGameRound] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var combo = 0
    @State private var bestCombo = 0
    @State private var totalMistakes = 0
    @State private var currentRoundComplete = false
    @State private var sessionComplete = false
    @State private var sessionIsNewBest = false
    @State private var sessionID = UUID()

    init(level: CEFRLevel, startingTopicID: String? = nil) {
        self.level = level
        self.startingTopicID = startingTopicID
        _bestScore = AppStorage(wrappedValue: 0, "sentenceBuilder.bestScore.\(level.rawValue)")
        _completedSessions = AppStorage(wrappedValue: 0, "sentenceBuilder.completedSessions.\(level.rawValue)")
    }

    private var currentRound: SentenceBuilderGameRound? {
        rounds.indices.contains(currentIndex) ? rounds[currentIndex] : nil
    }

    private var currentTopic: GrammarTopic? {
        guard let currentRound else { return nil }
        return allTopics.first { $0.id == currentRound.topicID }
    }

    private var availableTopicCount: Int {
        allTopics.lazy.filter { $0.cefrLevel == level && !$0.examples.isEmpty }.count
    }

    private var completedRoundCount: Int {
        min(rounds.count, currentIndex + (currentRoundComplete ? 1 : 0))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if sessionComplete {
                    completionView
                } else if let round = currentRound, let topic = currentTopic {
                    focusedGameStatus
                    GrammarStructureBuilder(
                        topic: topic,
                        fixedExample: round.example,
                        gameMode: true,
                        onSentenceCompleted: completeCurrentRound
                    )
                    .id(round.id)

                    if currentRoundComplete {
                        Button {
                            advance()
                        } label: {
                            if currentIndex == rounds.count - 1 {
                                TeachingLabel(english: "See game results", systemImage: "trophy.fill")
                            } else {
                                TeachingLabel(english: "Next sentence", systemImage: "arrow.right.circle.fill")
                            }
                        }
                        .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
                        .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .bottom)))
                    }
                } else if availableTopicCount > 0 {
                    CoachLoadingState(
                        title: "Preparing Sentence Builder",
                        message: "Choosing useful \(level.rawValue) sentences"
                    )
                } else {
                    CoachEmptyState(
                        icon: "rectangle.3.group.fill",
                        title: "No sentence rounds yet",
                        message: "The \(level.rawValue) grammar examples are still being prepared.",
                        tint: CoachTheme.accent
                    )
                }
            }
            .frame(maxWidth: 680)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
        }
        .teachingNavigationTitle("Sentence Builder")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    startSession()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .teachingAccessibilityLabel("Start a new sentence builder game")
            }
        }
        .task(id: "\(level.rawValue)-\(availableTopicCount)-\(startingTopicID ?? "all")") {
            if rounds.isEmpty {
                startSession()
            }
        }
        .animation(reduceMotion ? nil : CoachMotion.quick, value: currentRoundComplete)
    }

    private var focusedGameStatus: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                TeachingText(
                    english: "Sentence \(min(currentIndex + 1, rounds.count)) of \(rounds.count)"
                )
                .font(.callout.weight(.bold).monospacedDigit())

                Spacer(minLength: 4)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(CoachTheme.reward)
                    Text("\(score)")
                }
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(CoachTheme.accent)
                    Text("x\(combo)")
                }
                .contentTransition(.numericText())
            }
            .font(.caption.weight(.bold).monospacedDigit())

            LessonProgressBar(
                progress: Double(completedRoundCount) / Double(max(rounds.count, 1))
            )
        }
        .padding(.horizontal, 2)
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel(
            "Sentence \(min(currentIndex + 1, rounds.count)) of \(rounds.count), score \(score), combo \(combo)"
        )
    }

    private func gameHeader(topic: GrammarTopic) -> some View {
        CoachCard(padding: 11, tint: CoachTheme.accent) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 11) {
                    CoachMascot(mood: currentRoundComplete ? .correct : .welcome, size: 48)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 7) {
                            SkillChip(title: level.rawValue, color: CoachTheme.primary)
                            SkillChip(
                                title: "Round \(min(currentIndex + 1, rounds.count))/\(rounds.count)",
                                color: CoachTheme.accent
                            )
                        }
                        TeachingText(english: "Build the sentence, then learn exactly how and why it works.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                LessonProgressBar(
                    progress: Double(completedRoundCount) / Double(max(rounds.count, 1))
                )
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var scoreStrip: some View {
        HStack(spacing: 0) {
            gameMetric(value: "\(score)", label: "Score", icon: "star.fill", tint: CoachTheme.reward)
            Divider().frame(height: 38)
            gameMetric(
                value: "\(completedRoundCount)/\(rounds.count)",
                label: "Built",
                icon: "rectangle.3.group.fill",
                tint: CoachTheme.correct
            )
            Divider().frame(height: 38)
            gameMetric(value: "x\(combo)", label: "Combo", icon: "bolt.fill", tint: CoachTheme.accent)
        }
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface,
                    CoachTheme.accent.opacity(0.07),
                    CoachTheme.rewardGlow.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel(
            "Score \(score), \(completedRoundCount) of \(rounds.count) sentences built, combo \(combo)"
        )
    }

    private func gameMetric(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Text(value)
                    .monospacedDigit()
            }
            .font(.system(.callout, design: .rounded, weight: .bold))
            .contentTransition(.numericText())
            TeachingText(english: label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func roundIntroduction(topic: GrammarTopic) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                TeachingText(english: "Grammar focus")
            } icon: {
                Image(systemName: "scope")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(CoachTheme.speaking)
            TeachingText(english: topic.title)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            CoachCelebrationMark()
            VStack(spacing: 5) {
                TeachingText(english: "Sentence session complete")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                TeachingText(
                    english: "You built \(rounds.count) sentences and reviewed the reason behind every word position."
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }

            CoachCard(tint: CoachTheme.correct) {
                HStack(spacing: 0) {
                    gameMetric(value: "\(score)", label: "Score", icon: "star.fill", tint: CoachTheme.reward)
                    Divider().frame(height: 42)
                    gameMetric(value: "x\(bestCombo)", label: "Best combo", icon: "bolt.fill", tint: CoachTheme.accent)
                    Divider().frame(height: 42)
                    gameMetric(value: "\(totalMistakes)", label: "Retries", icon: "arrow.uturn.backward", tint: CoachTheme.listening)
                }
            }

            if sessionIsNewBest {
                TeachingLabel(english: "New best score", systemImage: "trophy.fill")
                    .font(.headline)
                    .foregroundStyle(CoachTheme.reward)
            }

            Button {
                startSession()
            } label: {
                TeachingLabel(english: "Play another session", systemImage: "arrow.clockwise")
            }
            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    private func completeCurrentRound(mistakes: Int) {
        guard !currentRoundComplete else { return }
        let nextCombo = mistakes == 0 ? combo + 1 : 0
        let accuracyPoints = max(40, 100 - (mistakes * 15))
        let comboBonus = mistakes == 0 ? min(nextCombo, 5) * 10 : 0

        withAnimation(reduceMotion ? nil : CoachMotion.spring) {
            totalMistakes += mistakes
            combo = nextCombo
            bestCombo = max(bestCombo, nextCombo)
            score += accuracyPoints + comboBonus
            currentRoundComplete = true
        }
    }

    private func advance() {
        guard currentRoundComplete else { return }
        if currentIndex == rounds.count - 1 {
            finishSession()
            return
        }

        withAnimation(reduceMotion ? nil : CoachMotion.quick) {
            currentIndex += 1
            currentRoundComplete = false
        }
        CoachFeedback.selection()
    }

    private func finishSession() {
        let maximumBaseScore = max(rounds.count * 100, 1)
        let baseScore = max(0, maximumBaseScore - (totalMistakes * 15))
        let accuracy = min(1, Double(baseScore) / Double(maximumBaseScore))
        let xp = 6 + rounds.count + min(bestCombo, 5)

        try? ProgressService().recordPractice(
            level: level,
            skill: .grammar,
            score: accuracy,
            xp: xp,
            sourceId: "sentence-builder-\(level.rawValue.lowercased())-\(sessionID.uuidString)",
            modelContext: modelContext
        )
        sessionIsNewBest = score > bestScore
        bestScore = max(bestScore, score)
        completedSessions += 1

        withAnimation(reduceMotion ? nil : CoachMotion.celebration) {
            sessionComplete = true
        }
        CoachFeedback.success()
    }

    private func startSession() {
        let newRounds = SentenceBuilderGameFactory.makeRounds(
            topics: allTopics,
            level: level,
            startingTopicID: startingTopicID
        )
        guard !newRounds.isEmpty else {
            rounds = []
            return
        }

        withAnimation(reduceMotion ? nil : CoachMotion.spring) {
            rounds = newRounds
            currentIndex = 0
            score = 0
            combo = 0
            bestCombo = 0
            totalMistakes = 0
            currentRoundComplete = false
            sessionComplete = false
            sessionIsNewBest = false
            sessionID = UUID()
        }
        CoachFeedback.selection()
    }
}

struct SentenceBuilderGameLink: View {
    @State private var premium = PremiumAccessService.shared
    let topic: GrammarTopic

    var body: some View {
        NavigationLink {
            if premium.isPremium {
                SentenceBuilderGameView(level: topic.cefrLevel, startingTopicID: topic.id)
            } else {
                PremiumLockedView(feature: .games)
            }
        } label: {
            HStack(spacing: 12) {
                CoachIconTile(icon: "rectangle.3.group.fill", tint: CoachTheme.accent, size: 48)
                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: "Open Sentence Builder game")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    TeachingText(
                        english: "Practice this pattern in focused rounds with a how-and-why explanation after every sentence."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                if !premium.isPremium {
                    PremiumLockBadge()
                }
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(CoachTheme.accent)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                CoachTheme.actionGradient(tint: CoachTheme.accent, companion: CoachTheme.speaking)
                    .opacity(0.11),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                    .stroke(CoachTheme.accent.opacity(0.24))
            )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityHint("Opens the standalone sentence-building game")
    }
}

struct GrammarStructurePracticeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let topic: GrammarTopic

    var body: some View {
        NavigationStack {
            PremiumGate(feature: .games) {
                SentenceBuilderGameView(level: topic.cefrLevel, startingTopicID: topic.id)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    TeachingButton("Done") { dismiss() }
                }
            }
        }
    }
}

struct GrammarStructureBuilder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let topic: GrammarTopic
    let fixedExample: ExampleSentence?
    let gameMode: Bool
    let onSentenceCompleted: ((Int) -> Void)?

    @State private var exampleIndex = 0
    @State private var sentenceTokens: [GrammarBuilderToken] = []
    @State private var availableTokens: [GrammarBuilderToken] = []
    @State private var placedTokens: [GrammarBuilderToken] = []
    @State private var selectedReasonIndex: Int?
    @State private var invalidTokenID: String?
    @State private var feedbackMessage: String?
    @State private var mistakeCount = 0
    @State private var isComplete = false

    init(
        topic: GrammarTopic,
        fixedExample: ExampleSentence? = nil,
        gameMode: Bool = false,
        onSentenceCompleted: @escaping ((Int) -> Void) = { _ in }
    ) {
        self.topic = topic
        self.fixedExample = fixedExample
        self.gameMode = gameMode
        self.onSentenceCompleted = onSentenceCompleted
    }

    private var examples: [ExampleSentence] {
        fixedExample.map { [$0] } ?? topic.examples
    }

    private var example: ExampleSentence? {
        examples.indices.contains(exampleIndex) ? examples[exampleIndex] : examples.first
    }

    private var activeReasonIndex: Int {
        guard !sentenceTokens.isEmpty else { return 0 }
        if let selectedReasonIndex {
            return min(selectedReasonIndex, sentenceTokens.count - 1)
        }
        return min(placedTokens.count, sentenceTokens.count - 1)
    }

    private var activeCue: GrammarPositionCue {
        GrammarStructureReasoner.cue(
            at: activeReasonIndex,
            tokens: sentenceTokens,
            topicID: topic.id
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if !gameMode {
                builderHeader
            }

            if let example {
                meaningPrompt(example)
                if !gameMode {
                    structureMap
                }
                sentenceWorkspace
                if !gameMode {
                    reasonPanel
                }

                if let feedbackMessage {
                    CoachFeedbackPanel(
                        isCorrect: false,
                        title: "Try a different position",
                        message: feedbackMessage
                    )
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top)))
                }

                if isComplete {
                    completionPanel(example)
                } else {
                    wordBank
                }

                actionBar(example)
            } else {
                CoachEmptyState(
                    icon: "rectangle.3.group.fill",
                    title: "No model sentence",
                    message: "This topic needs an example before sentence-building practice can begin.",
                    tint: CoachTheme.accent
                )
            }
        }
        .onAppear(perform: prepareSentence)
        .onChange(of: exampleIndex) { _, _ in prepareSentence() }
        .animation(reduceMotion ? nil : CoachMotion.quick, value: feedbackMessage)
        .accessibilityElement(children: .contain)
    }

    private var builderHeader: some View {
        HStack(spacing: 11) {
            Image(systemName: "rectangle.3.group.fill")
                .font(.body.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    CoachTheme.actionGradient(tint: CoachTheme.accent, companion: CoachTheme.speaking),
                    in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                )
            VStack(alignment: .leading, spacing: 2) {
                TeachingText(english: "Build the German structure")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                TeachingText(english: "Tap words in order. The reason changes with each sentence position.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func meaningPrompt(_ example: ExampleSentence) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label {
                TeachingText(english: "Meaning to express")
            } icon: {
                Image(systemName: "quote.bubble.fill")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(CoachTheme.listening)

            TeachingText(english: example.english)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoachTheme.listening.opacity(0.09), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.listening.opacity(0.18)))
    }

    private var structureMap: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(GrammarStructureReasoner.guide(for: topic.id)) { cue in
                    TeachingLabel(english: cue.shortTitle, systemImage: cue.icon)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(cue.tint)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 7)
                        .background(cue.tint.opacity(0.10), in: Capsule())
                        .overlay(Capsule().stroke(cue.tint.opacity(0.20)))
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .teachingAccessibilityLabel("Sentence position guide")
    }

    private var sentenceWorkspace: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                TeachingText(english: "Your sentence")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CoachTheme.primary)
                Spacer()
                if !placedTokens.isEmpty, !isComplete {
                    Button {
                        undoLastToken()
                        CoachFeedback.selection()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.accent))
                    .teachingAccessibilityLabel("Return the last word")
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.92)))
                }
                Text("\(placedTokens.count)/\(sentenceTokens.count)")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.secondary)
            }

            GrammarTokenFlowLayout(spacing: 7) {
                ForEach(sentenceTokens.indices, id: \.self) { index in
                    if placedTokens.indices.contains(index) {
                        placedToken(placedTokens[index], at: index)
                    } else {
                        emptySlot(at: index)
                    }
                }
            }

            LessonProgressBar(
                progress: Double(placedTokens.count) / Double(max(sentenceTokens.count, 1))
            )
        }
        .padding(12)
        .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
    }

    private func placedToken(_ token: GrammarBuilderToken, at index: Int) -> some View {
        let cue = GrammarStructureReasoner.cue(at: index, tokens: sentenceTokens, topicID: topic.id)
        return Button {
            selectedReasonIndex = index
            CoachFeedback.selection()
        } label: {
            VStack(spacing: 2) {
                Text(token.text)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .environment(\.layoutDirection, .leftToRight)
                    .multilineTextAlignment(.center)
                if !gameMode || isComplete {
                    TeachingText(english: cue.shortTitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(cue.tint)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(cue.tint.opacity(0.11), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(cue.tint.opacity(0.28)))
        }
        .buttonStyle(.plain)
        .teachingAccessibilityLabel(
            "\(token.text), \(cue.title)",
            protectedGerman: [token.text]
        )
        .teachingAccessibilityHint("Shows why this word is in this position")
    }

    private func emptySlot(at index: Int) -> some View {
        let cue = GrammarStructureReasoner.cue(at: index, tokens: sentenceTokens, topicID: topic.id)
        return VStack(spacing: 2) {
            Text("\(index + 1)")
                .font(.caption.monospacedDigit().weight(.bold))
            if !gameMode {
                TeachingText(english: cue.shortTitle)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(index == placedTokens.count ? cue.tint : Color.secondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                .fill(index == placedTokens.count ? cue.tint.opacity(0.08) : Color.clear)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                .stroke(
                    index == placedTokens.count ? cue.tint.opacity(0.55) : CoachTheme.stroke,
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )
        }
        .teachingAccessibilityLabel("Empty position \(index + 1), \(cue.title)")
    }

    private var reasonPanel: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: activeCue.icon)
                .font(.callout.weight(.bold))
                .foregroundStyle(activeCue.tint)
                .frame(width: 32, height: 32)
                .background(activeCue.tint.opacity(0.11), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: activeCue.title)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(activeCue.tint)
                TeachingText(english: activeCue.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .id(activeReasonIndex)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
    }

    private var wordBank: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                TeachingText(english: placedTokens.isEmpty ? "Choose the sentence opening" : "Choose the next word")
            } icon: {
                Image(systemName: "hand.tap.fill")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(CoachTheme.accent)

            GrammarTokenFlowLayout(spacing: 8) {
                ForEach(availableTokens) { token in
                    Button {
                        place(token)
                    } label: {
                        Text(token.text)
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .environment(\.layoutDirection, .leftToRight)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 9)
                            .foregroundStyle(invalidTokenID == token.id ? CoachTheme.incorrect : CoachTheme.ink)
                            .background(
                                (invalidTokenID == token.id ? CoachTheme.incorrect : CoachTheme.primary).opacity(0.09),
                                in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
                                    .stroke(
                                        (invalidTokenID == token.id ? CoachTheme.incorrect : CoachTheme.primary)
                                            .opacity(invalidTokenID == token.id ? 0.60 : 0.22)
                                    )
                            }
                    }
                    .buttonStyle(CoachCardButtonStyle())
                    .draggable(token.id)
                    .teachingAccessibilityHint("Places this word into the next sentence position")
                }
            }
        }
    }

    private func completionPanel(_ example: ExampleSentence) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            CoachFeedbackPanel(
                isCorrect: true,
                title: mistakeCount == 0 ? "Perfect structure" : "Sentence structure complete",
                message: mistakeCount == 0
                    ? "You built the sentence without a positioning mistake."
                    : "You corrected the word order and completed the sentence."
            )

            TeachingLabel(english: "Now see how and why it works", systemImage: "lightbulb.max.fill")
                .font(.headline)
                .foregroundStyle(CoachTheme.reward)

            HStack(alignment: .top, spacing: 9) {
                Text(example.german)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .environment(\.layoutDirection, .leftToRight)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                GermanSpeechButton(text: example.german, label: "Play completed sentence")
                GrammarXRayButton(sentence: example.german, topic: topic)
            }

            GrammarSentenceExplanation(
                topic: topic,
                example: example,
                tokens: sentenceTokens
            )
        }
        .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.98)))
    }

    private func actionBar(_ example: ExampleSentence) -> some View {
        HStack(spacing: 9) {
            if !isComplete {
                Button {
                    restartSentence()
                    CoachFeedback.selection()
                } label: {
                    TeachingLabel(
                        english: gameMode ? "Restart" : "Reset",
                        systemImage: "arrow.counterclockwise"
                    )
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.accent))
            }

            if isComplete || !gameMode {
                Button {
                    GermanSpeechService.shared.speak(example.german, style: .sentence)
                } label: {
                    TeachingLabel(english: "Hear model", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))
            }

            if !gameMode, examples.count > 1, isComplete {
                Button {
                    exampleIndex = (exampleIndex + 1) % examples.count
                    CoachFeedback.selection()
                } label: {
                    Image(systemName: "arrow.right")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.correct))
                .teachingAccessibilityLabel("Build another example")
            }
        }
    }

    private func prepareSentence() {
        guard let example else {
            sentenceTokens = []
            availableTokens = []
            placedTokens = []
            return
        }

        let source = example.german
            .split(whereSeparator: \.isWhitespace)
            .enumerated()
            .map { index, word in
                GrammarBuilderToken(id: "\(exampleIndex)-\(index)-\(word)", text: String(word))
            }

        sentenceTokens = source
        availableTokens = shuffled(source)
        placedTokens = []
        selectedReasonIndex = nil
        invalidTokenID = nil
        feedbackMessage = nil
        mistakeCount = 0
        isComplete = false
    }

    private func restartSentence() {
        let retryCount = gameMode ? mistakeCount + 1 : 0
        prepareSentence()
        mistakeCount = retryCount
    }

    private func place(_ token: GrammarBuilderToken) {
        guard sentenceTokens.indices.contains(placedTokens.count) else { return }
        let expected = sentenceTokens[placedTokens.count]

        guard GrammarStructureReasoner.normalized(token.text) == GrammarStructureReasoner.normalized(expected.text) else {
            mistakeCount += 1
            invalidTokenID = token.id
            let cue = GrammarStructureReasoner.cue(
                at: placedTokens.count,
                tokens: sentenceTokens,
                topicID: topic.id
            )
            feedbackMessage = gameMode
                ? "That word does not fit in the next space yet. Try another word."
                : "This position needs \(cue.shortTitle.lowercased()). \(cue.reason)"
            CoachFeedback.warning()
            DispatchQueue.main.asyncAfter(deadline: .now() + CoachMotion.standardDuration) {
                if invalidTokenID == token.id {
                    invalidTokenID = nil
                }
            }
            return
        }

        let completesSentence = placedTokens.count + 1 == sentenceTokens.count
        let update = {
            availableTokens.removeAll { $0.id == token.id }
            placedTokens.append(token)
            selectedReasonIndex = placedTokens.count - 1
            feedbackMessage = nil
            invalidTokenID = nil
            isComplete = completesSentence
        }
        if reduceMotion {
            update()
        } else {
            withAnimation(CoachMotion.quick) {
                update()
            }
        }

        if completesSentence {
            CoachFeedback.success()
            onSentenceCompleted?(mistakeCount)
        } else {
            CoachFeedback.selection()
        }
    }

    private func undoLastToken() {
        guard let token = placedTokens.last else { return }
        let update = {
            _ = placedTokens.popLast()
            availableTokens.append(token)
            selectedReasonIndex = placedTokens.indices.last
            feedbackMessage = nil
            isComplete = false
        }
        if reduceMotion {
            update()
        } else {
            withAnimation(CoachMotion.quick) {
                update()
            }
        }
    }

    private func shuffled(_ source: [GrammarBuilderToken]) -> [GrammarBuilderToken] {
        guard source.count > 1 else { return source }
        var result = source.shuffled()
        if result.map(\.text) == source.map(\.text) {
            result.append(result.removeFirst())
        }
        return result
    }
}

struct GrammarSentenceExplanation: View {
    let topic: GrammarTopic
    let example: ExampleSentence
    let tokens: [GrammarBuilderToken]

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            explanationSection(
                title: "How this sentence is built",
                icon: "square.grid.3x1.folder.badge.plus",
                tint: CoachTheme.accent
            ) {
                GrammarTokenFlowLayout(spacing: 7) {
                    ForEach(tokens.indices, id: \.self) { index in
                        tokenRole(tokens[index], at: index)
                    }
                }
            }

            Divider()

            explanationSection(
                title: "Why this order is correct",
                icon: "lightbulb.fill",
                tint: CoachTheme.reward
            ) {
                TeachingText(
                    english: GrammarStructureReasoner.sentenceReason(
                        topicID: topic.id,
                        tokens: tokens
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            explanationSection(
                title: "Rule behind this sentence",
                icon: "book.closed.fill",
                tint: CoachTheme.primary
            ) {
                TeachingText(english: topic.explanation)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .foregroundStyle(CoachTheme.listening)
                TeachingText(english: "Meaning: \(example.english)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(13)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface,
                    CoachTheme.accent.opacity(0.055),
                    CoachTheme.rewardGlow.opacity(0.055)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
        .accessibilityElement(children: .contain)
    }

    private func tokenRole(_ token: GrammarBuilderToken, at index: Int) -> some View {
        let cue = GrammarStructureReasoner.cue(at: index, tokens: tokens, topicID: topic.id)
        return VStack(spacing: 3) {
            Text(token.text)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .environment(\.layoutDirection, .leftToRight)
                .multilineTextAlignment(.center)
            TeachingText(english: cue.shortTitle)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(cue.tint)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(cue.tint.opacity(0.10), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(cue.tint.opacity(0.24)))
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel(
            "\(token.text), \(cue.title). \(cue.reason)",
            protectedGerman: [token.text]
        )
    }

    private func explanationSection<Content: View>(
        title: String,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                TeachingText(english: title)
            } icon: {
                Image(systemName: icon)
            }
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundStyle(tint)
            content()
        }
    }
}

struct GrammarBuilderToken: Identifiable, Hashable {
    let id: String
    let text: String
}

struct GrammarPositionCue: Identifiable {
    let id: String
    let shortTitle: String
    let title: String
    let reason: String
    let icon: String
    let tint: Color
}

enum GrammarStructureReasoner {
    private static let subordinateConnectors: Set<String> = [
        "als", "auch", "bevor", "dass", "damit", "falls", "indem", "nachdem",
        "ob", "obwohl", "ohne", "sobald", "sodass", "während", "weil", "wenn", "wo", "was"
    ]
    private static let questionWords: Set<String> = [
        "wer", "wen", "wem", "wessen", "was", "wann", "wo", "wohin", "woher",
        "warum", "wie", "welche", "welcher", "welches"
    ]
    private static let finiteVerbs: Set<String> = [
        "arbeite", "arbeitet", "beginne", "beginnt", "bin", "bist", "bleibe", "bleibt",
        "fahre", "fährst", "fährt", "gab", "gebe", "gibt", "gehe", "geht", "habe",
        "haben", "hast", "hat", "hatte", "heiße", "heißt", "helfe", "hilft", "ist",
        "kann", "kannst", "kannte", "kommen", "kommst", "kommt", "können", "könnt",
        "lerne", "lernt", "lässt", "mache", "macht", "melde", "melden", "muss", "musst",
        "musste", "müssen", "öffnen", "öffnet", "regnet", "sage", "sagt", "seid", "sind",
        "spreche", "spricht", "stehe", "steht", "trenne", "trennt", "treffe", "treffen",
        "trifft", "versuche", "versucht", "war", "waren", "warte", "wartet", "wasche",
        "wäscht", "werde", "werden", "wird", "wohne", "wohnt", "würde"
    ]
    private static let subjectPronouns: Set<String> = [
        "ich", "du", "er", "sie", "es", "wir", "ihr", "man"
    ]
    private static let dativeMarkers: Set<String> = [
        "dem", "einem", "einer", "mir", "dir", "ihm", "ihnen", "uns", "euch"
    ]
    private static let accusativeMarkers: Set<String> = [
        "den", "einen", "mich", "dich", "ihn"
    ]

    static func normalized(_ value: String) -> String {
        String(value.lowercased().filter(\.isLetter))
    }

    static func guide(for topicID: String) -> [GrammarPositionCue] {
        if isQuestion(topicID) {
            return [
                cue("question", "Question lead", "Question opening", "A question word or conjugated verb opens the question.", "questionmark.bubble.fill", CoachTheme.listening),
                cue("verb", "Verb anchor", "Verb position", "The conjugated verb comes first in yes/no questions or directly after the question word.", "bolt.fill", CoachTheme.speaking),
                cue("subject", "Subject", "Who or what?", "The subject follows the question opening and controls the verb ending.", "person.fill", GermanGrammarCase.nominative.color),
                cue("middle", "Details", "Question details", "Objects, time, manner and place complete the information request.", "square.grid.2x2.fill", CoachTheme.accent)
            ]
        }
        if isSubordinate(topicID) {
            return [
                cue("main", "Main idea", "Main clause", "State the independent idea before or after the dependent clause.", "text.bubble.fill", CoachTheme.listening),
                cue("connector", "Connector", "Dependent-clause signal", "The connector tells the listener why, when, under what condition, or despite what.", "link", CoachTheme.accent),
                cue("middle", "Subject + details", "Dependent middle field", "The subject and its details follow the connector.", "person.text.rectangle.fill", GermanGrammarCase.nominative.color),
                cue("end", "Verb at end", "Dependent-clause verb", "The conjugated verb closes the dependent clause.", "arrow.down.to.line.compact", CoachTheme.correct)
            ]
        }
        if hasVerbFrame(topicID) {
            return [
                cue("start", "Starting field", "Sentence opening", "Choose one idea as the starting point.", "1.circle.fill", CoachTheme.listening),
                cue("verb", "Finite verb", "Conjugated verb anchor", "The conjugated verb holds position two in a normal statement.", "2.circle.fill", CoachTheme.speaking),
                cue("middle", "Middle field", "Sentence details", "Subject, time, objects, manner and place fill the middle.", "ellipsis.rectangle.fill", CoachTheme.accent),
                cue("end", "Verb partner", "Sentence bracket", "The infinitive, participle or separable prefix closes the verb frame.", "arrow.right.to.line", CoachTheme.correct)
            ]
        }
        if topicID.contains("dative") || topicID.contains("accusative") || topicID.contains("object") {
            return [
                cue("subject", "Nominative", "Subject role", "The nominative names who performs or experiences the action.", GermanGrammarCase.nominative.icon, GermanGrammarCase.nominative.color),
                cue("verb", "Verb", "Action anchor", "The conjugated verb connects the subject with its objects.", "bolt.fill", CoachTheme.speaking),
                cue("dative", "Dative", "Receiver role", "The dative often names the receiver or affected person.", GermanGrammarCase.dative.icon, GermanGrammarCase.dative.color),
                cue("accusative", "Accusative", "Direct-object role", "The accusative often names what is directly acted upon.", GermanGrammarCase.accusative.icon, GermanGrammarCase.accusative.color)
            ]
        }
        return [
            cue("start", "Starting field", "Sentence opening", "Put one complete idea or chunk before the conjugated verb.", "1.circle.fill", CoachTheme.listening),
            cue("verb", "Finite verb", "Position-two anchor", "In a normal statement, the conjugated verb is the second sentence chunk.", "2.circle.fill", CoachTheme.speaking),
            cue("middle", "Middle field", "Sentence details", "The subject, objects, time, manner and place fit around the meaning.", "ellipsis.rectangle.fill", CoachTheme.accent),
            cue("end", "End field", "Sentence ending", "Finish the idea with the final detail or verb partner.", "flag.checkered", CoachTheme.correct)
        ]
    }

    static func sentenceReason(
        topicID: String,
        tokens: [GrammarBuilderToken]
    ) -> String {
        if isQuestion(topicID) {
            let firstWord = tokens.first.map { normalized($0.text) } ?? ""
            if questionWords.contains(firstWord) {
                return "The question word comes first because it names the missing information. The conjugated verb follows it, then the subject and the remaining details."
            }
            return "This is a yes-or-no question, so the conjugated verb comes first. The subject follows it, and the remaining words complete the question."
        }

        if isSubordinate(topicID) {
            return "The connector opens a dependent clause. German keeps the subject and its details inside that clause, then places the conjugated verb at the end so the clause is clearly complete."
        }

        if hasVerbFrame(topicID) {
            return "The conjugated verb anchors the second sentence field. Its infinitive, participle, or separated partner closes the sentence bracket, while the important details sit between those two parts."
        }

        if topicID.contains("dative") || topicID.contains("accusative") || topicID.contains("object") {
            return "The subject names who performs the action. The verb anchors the sentence, the dative identifies a receiver or affected person, and the accusative identifies what is directly acted upon."
        }

        return "This is a main statement. One complete idea fills the first field, the conjugated verb anchors the second field, and the subject, objects, time, manner, or place details follow in a logical order."
    }

    static func cue(
        at index: Int,
        tokens: [GrammarBuilderToken],
        topicID: String
    ) -> GrammarPositionCue {
        guard tokens.indices.contains(index) else {
            return cue("start", "Start", "Sentence opening", "Begin with the idea you want the listener to notice first.", "1.circle.fill", CoachTheme.listening)
        }

        let word = normalized(tokens[index].text)
        let connectorIndex = firstConnectorIndex(in: tokens, topicID: topicID)
        let firstFiniteIndex = tokens.indices.first {
            finiteVerbs.contains(normalized(tokens[$0].text))
        }

        if isConnector(at: index, tokens: tokens, topicID: topicID) {
            return cue("connector-\(index)", "Connector", "Dependent-clause connector", "This word opens a dependent idea, so its conjugated verb moves to the end of that clause.", "link", CoachTheme.accent)
        }

        if questionWords.contains(word), index == 0 {
            return cue("question-\(index)", "Question lead", "Question word first", "The question word names the missing information. The conjugated verb follows it.", "questionmark.bubble.fill", CoachTheme.listening)
        }

        if finiteVerbs.contains(word) {
            if isQuestion(topicID), index == 0 {
                return cue("verb-first-\(index)", "Verb first", "Yes/no question", "A yes/no question begins with the conjugated verb, followed by the subject.", "1.circle.fill", CoachTheme.speaking)
            }
            if isInsideDependentClause(index: index, connectorIndex: connectorIndex, tokens: tokens) {
                return cue("verb-end-\(index)", "Verb at end", "Dependent-clause anchor", "The connector sends the conjugated verb to the end of this dependent clause.", "arrow.down.to.line.compact", CoachTheme.correct)
            }
            return cue("finite-\(index)", "Finite verb", "Conjugated verb anchor", "This verb carries person and tense. In a normal main clause it occupies the second sentence chunk.", "bolt.fill", CoachTheme.speaking)
        }

        if dativeMarkers.contains(word) {
            return cue("dative-\(index)", "Dative", "Receiver or affected person", "The dative form marks who receives, benefits from, or is affected by the action.", GermanGrammarCase.dative.icon, GermanGrammarCase.dative.color)
        }

        if accusativeMarkers.contains(word) {
            return cue("accusative-\(index)", "Accusative", "Direct object", "The accusative form marks the person or thing directly affected by the action.", GermanGrammarCase.accusative.icon, GermanGrammarCase.accusative.color)
        }

        if subjectPronouns.contains(word) {
            return cue("subject-\(index)", "Subject", "Nominative subject", "This word identifies who performs or experiences the action and controls the verb ending.", GermanGrammarCase.nominative.icon, GermanGrammarCase.nominative.color)
        }

        if let connectorIndex, index == connectorIndex + 1 {
            return cue("subject-zone-\(index)", "Subject zone", "Dependent-clause subject", "After the connector, German normally identifies who or what the dependent clause is about.", "person.fill", GermanGrammarCase.nominative.color)
        }

        if let firstFiniteIndex, index < firstFiniteIndex {
            return cue("start-\(index)", "Starting field", "Before the finite verb", "This word belongs to the first sentence chunk. The complete chunk occupies the field before the conjugated verb.", "1.circle.fill", CoachTheme.listening)
        }

        if index == tokens.count - 1, hasVerbFrame(topicID) {
            return cue("frame-end-\(index)", "Verb partner", "Sentence bracket closes", "This infinitive, participle, or separable element completes the verb meaning at the end.", "arrow.right.to.line", CoachTheme.correct)
        }

        if index == 0 {
            return cue("start-\(index)", "Starting field", "Sentence opening", "German starts with the idea the speaker wants to connect to the sentence. The finite verb anchors what follows.", "1.circle.fill", CoachTheme.listening)
        }

        return cue("middle-\(index)", "Middle field", "Meaning detail", "This position carries a subject, object, time, manner, place, or another detail between the verb anchors.", "ellipsis.rectangle.fill", CoachTheme.accent)
    }

    private static func cue(
        _ id: String,
        _ shortTitle: String,
        _ title: String,
        _ reason: String,
        _ icon: String,
        _ tint: Color
    ) -> GrammarPositionCue {
        GrammarPositionCue(id: id, shortTitle: shortTitle, title: title, reason: reason, icon: icon, tint: tint)
    }

    private static func isQuestion(_ topicID: String) -> Bool {
        topicID.contains("question") || topicID.contains("formal-address")
    }

    private static func isSubordinate(_ topicID: String) -> Bool {
        [
            "subordinate", "relative", "causal", "temporal", "conditional", "concessive",
            "indirect-speech", "result-manner", "plusquamperfekt", "purpose", "extended-infinitives"
        ].contains { topicID.contains($0) }
    }

    private static func hasVerbFrame(_ topicID: String) -> Bool {
        [
            "modal", "perfect", "separable", "infinitive", "passive", "future",
            "participle", "plusquamperfekt", "konjunktiv", "alternatives", "purpose"
        ].contains { topicID.contains($0) }
    }

    private static func firstConnectorIndex(
        in tokens: [GrammarBuilderToken],
        topicID: String
    ) -> Int? {
        tokens.indices.first {
            isConnector(at: $0, tokens: tokens, topicID: topicID)
        }
    }

    private static func isConnector(
        at index: Int,
        tokens: [GrammarBuilderToken],
        topicID: String
    ) -> Bool {
        if isRelativeLink(at: index, tokens: tokens, topicID: topicID) {
            return true
        }
        guard isSubordinate(topicID), tokens.indices.contains(index) else { return false }
        let word = normalized(tokens[index].text)
        if word == "auch" {
            guard tokens.indices.contains(index + 1) else { return false }
            return normalized(tokens[index + 1].text) == "wenn"
        }
        return subordinateConnectors.contains(word)
    }

    private static func isRelativeLink(
        at index: Int,
        tokens: [GrammarBuilderToken],
        topicID: String
    ) -> Bool {
        guard topicID.contains("relative"), index > 0 else { return false }
        let followsComma = tokens[index - 1].text.contains(",")
            || (index > 1 && tokens[index - 2].text.contains(","))
        guard followsComma else { return false }
        return ["der", "die", "das", "den", "dem", "deren", "dessen", "mit", "wo", "was"]
            .contains(normalized(tokens[index].text))
    }

    private static func isInsideDependentClause(
        index: Int,
        connectorIndex: Int?,
        tokens: [GrammarBuilderToken]
    ) -> Bool {
        guard let connectorIndex, index > connectorIndex else { return false }
        if let commaIndex = tokens.indices.first(where: { $0 >= connectorIndex && tokens[$0].text.contains(",") }) {
            return index <= commaIndex
        }
        return true
    }
}

private struct GrammarTokenFlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var position = CGPoint.zero
        var lineHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = fittedSize(for: subview, maxWidth: maxWidth)
            if position.x > 0, position.x + size.width > maxWidth {
                position.x = 0
                position.y += lineHeight + spacing
                lineHeight = 0
            }
            usedWidth = max(usedWidth, position.x + size.width)
            position.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(
            width: maxWidth.isFinite ? maxWidth : usedWidth,
            height: position.y + lineHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var position = CGPoint(x: bounds.minX, y: bounds.minY)
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = fittedSize(for: subview, maxWidth: bounds.width)
            if position.x > bounds.minX, position.x + size.width > bounds.maxX {
                position.x = bounds.minX
                position.y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(
                at: position,
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            position.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }

    private func fittedSize(for subview: LayoutSubview, maxWidth: CGFloat) -> CGSize {
        let ideal = subview.sizeThatFits(.unspecified)
        guard maxWidth.isFinite, ideal.width > maxWidth else { return ideal }
        return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
    }
}

struct GrammarPlainLanguageGuide: View {
    let topic: GrammarTopic

    private var model: ExampleSentence? { topic.examples.first }
    private var visualRule: GrammarVisualSpec { GrammarVisualCatalog.spec(for: topic.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Label {
                    TeachingText(english: "Plain rule")
                } icon: {
                    Image(systemName: "lightbulb.fill")
                }
                .font(.headline)
                .foregroundStyle(CoachTheme.primary)
                TeachingText(english: topic.explanation)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            guideStep(1, title: "Start with the meaning", tint: CoachTheme.listening) {
                TeachingText(
                    english: model.map { "Start from this meaning: “\($0.english)”" }
                        ?? "Decide the exact idea you want the listener to understand."
                )
            }
            guideStep(2, title: "Build the German pattern", tint: CoachTheme.accent) {
                VStack(alignment: .leading, spacing: 4) {
                    if let model {
                        TeachingText(english: "Copy this safe German model:")
                        HStack(alignment: .top, spacing: 8) {
                            Text("“\(model.german)”")
                                .fontWeight(.semibold)
                                .environment(\.layoutDirection, .leftToRight)
                            Spacer(minLength: 4)
                            GrammarXRayButton(sentence: model.german, topic: topic)
                        }
                    }
                    TeachingText(english: visualRule.caption)
                }
            }
            guideStep(3, title: "Check one common trap", tint: CoachTheme.speaking) {
                TeachingText(
                    english: topic.commonMistakes.first.map { "Watch for this: \($0)" }
                        ?? "Read the finished sentence once and check the verb position."
                )
            }
        }
    }

    private func guideStep<Content: View>(
        _ number: Int,
        title: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Text("\(number)")
                .font(.caption.weight(.heavy).monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(tint, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: title)
                    .font(.callout.weight(.bold))
                content()
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct HighlightedLearningSentence: View {
    let sentence: String
    let target: String
    let tint: Color

    var body: some View {
        if let range = matchingRange {
            (Text(String(sentence[..<range.lowerBound]))
                + Text(String(sentence[range])).bold().foregroundColor(tint)
                + Text(String(sentence[range.upperBound...])))
        } else {
            Text(sentence)
        }
    }

    private var matchingRange: Range<String.Index>? {
        let cleanedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
        let directCandidates = [cleanedTarget]
            .filter { $0.count > 1 }
        for candidate in directCandidates {
            if let range = sentence.range(of: candidate, options: [.caseInsensitive, .diacriticInsensitive]) {
                return range
            }
        }

        let stem: String
        if cleanedTarget.count > 5 && cleanedTarget.lowercased().hasSuffix("en") {
            stem = String(cleanedTarget.dropLast(2))
        } else if cleanedTarget.count > 4 && cleanedTarget.lowercased().hasSuffix("n") {
            stem = String(cleanedTarget.dropLast())
        } else {
            stem = cleanedTarget
        }
        guard stem.count >= 4 else { return nil }
        return sentence.range(of: stem, options: [.caseInsensitive, .diacriticInsensitive])
    }
}
