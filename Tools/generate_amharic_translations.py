#!/usr/bin/env python3
"""Generate the offline English-to-Amharic teaching-text catalog.

This is a development-time utility. It sends only app-authored curriculum text,
never learner data, and writes a deterministic JSON resource bundled with the app.
"""

from __future__ import annotations

import argparse
import json
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESOURCE_DIR = ROOT / "DeutschB1Coach" / "Resources"
SOURCE_DIR = ROOT / "DeutschB1Coach"
DEFAULT_LANGUAGE = "am"

CORE_INTERFACE_SOURCES = [
    "Beginner German",
    "Everyday German",
    "Independent German",
    "Build the foundations for everyday life",
    "Handle common situations with confidence",
    "Express yourself clearly and prepare for the exam",
    "Arrive and connect",
    "Manage everyday life",
    "Use local services",
    "Work and participate",
    "Communicate independently",
    "B1 and DTZ readiness",
    "Basiskurs 1 · Identity, first contacts, and essential daily tasks",
    "Basiskurs 2 · Mobility, health, work, learning, and public services",
    "Basiskurs 3 · Housing, travel, health, work, and family services",
    "Aufbausprachkurs 1 · Communication, public life, education, and administration",
    "Aufbausprachkurs 2 · Work, education, media, society, and health",
    "Aufbausprachkurs 3 · Formal requests, conflict resolution, participation, and exam transfer",
    "A1 Course Book",
    "A2 Course Book",
    "B1 Course Book",
    "A1 COURSE BOOK",
    "A2 COURSE BOOK",
    "B1 COURSE BOOK",
    "Chapters",
    "Complete each chapter to open the next one",
    "Start next lesson",
    "Continue learning",
]

REQUIRED_MICROCOPY_SOURCES = [
    "Explain more simply",
    "Opens a shorter explanation with one example and a self-check",
    "ONE IDEA",
    "Think of it like this",
    "Three tiny steps",
    "Do only one step at a time",
    "One safe model",
    "Play simple model",
    "Quick check",
    "Show the simple answer",
    "Close simple explanation",
    "Simple explanation",
    "Opens the teaching language picker",
    "Explanations and instructions use this language. German learning content always stays German.",
    "Selected",
    "Not selected",
]

PROTECTED_GERMAN_TERMS = [
    "Konjunktiv II", "Plusquamperfekt", "Partizip II",
    "N-Deklination", "Nominalisierung", "Relativsatz",
    "Nominativ", "Akkusativ", "Dativ", "Genitiv",
    "Perfekt", "Präteritum", "Passiv",
    "Ä", "Ö", "Ü", "ß",
    "um ... zu", "um...zu", "ohne ... zu", "ohne...zu",
    "statt ... zu", "statt...zu",
    "sein", "haben", "werden",
    "ich", "du", "er", "sie", "es", "wir", "ihr", "Sie",
    "mich", "dich", "ihn", "uns", "euch", "ihnen",
    "mir", "dir", "ihm",
    "der", "die", "das", "den", "dem", "des",
    "ein", "eine", "einen", "einem", "einer", "eines",
    "kein", "keine", "keinen", "keinem", "keiner", "keines",
    "nicht", "weil", "dass", "wenn", "obwohl", "trotzdem",
    "damit", "als", "bevor", "nachdem", "indem", "sodass",
    "doch", "mal", "eben", "wohl",
]

TRANSLATE_URL = "https://translate.googleapis.com/translate_a/single"
GERMAN_TOKEN_PATTERN = re.compile(r"(ZXQGERMAN\d+QXZ)", flags=re.IGNORECASE)
MAX_BATCH_CHARACTERS = 3_600
MAX_BATCH_ITEMS = 24

MANUAL_OVERRIDES = {
    "German Alphabet and Sounds": "የጀርመንኛ ፊደላትና ድምፆች",
    "Personal Pronouns": "የግል ተውላጠ ስሞች",
    "Sein and Haben": "sein እና haben",
    "Present Tense Verbs": "የአሁን ጊዜ ግሶች",
    "Nominative Articles": "የNominativ አርቲክሎች",
    "Accusative Articles": "የAkkusativ አርቲክሎች",
    "Negation with Nicht and Kein": "በnicht እና kein አሉታዊ አገላለጽ",
    "Main-Clause Word Order": "በዋና ሐረግ ውስጥ የቃላት ቅደም ተከተል",
    "Questions": "ጥያቄዎች",
    "Modal Verbs": "ሞዳል ግሶች",
    "Possessive Articles": "የባለቤትነት አርቲክሎች",
    "Plural Nouns": "ብዙ ቁጥር ስሞች",
    "Basic Prepositions": "መሠረታዊ መስተዋድዶች",
    "Separable Verbs": "የሚነጣጠሉ ግሶች",
    "Perfect Tense Basics": "የPerfekt ጊዜ መሠረቶች",
    "Adjectives after Sein": "ከsein በኋላ የሚመጡ ቅጽሎች",
    "Connecting Main Clauses": "ዋና ሐረጎችን ማገናኘት",
    "Time, Days, and Dates": "ሰዓት፣ የሳምንቱ ቀናትና ቀኖች",
    "Accusative Personal Pronouns": "የAkkusativ የግል ተውላጠ ስሞች",
    "Polite and Informal Commands": "ጨዋነት ያላቸውና መደበኛ ያልሆኑ ትዕዛዞች",
    "Wo, Wohin, and Woher": "wo, wohin እና woher",
    "Du, Ihr, and Formal Sie": "du, ihr እና መደበኛው Sie",
    "Dative Personal Pronouns": "የDativ የግል ተውላጠ ስሞች",
    "Simple Comparisons": "ቀላል ንጽጽሮች",
    "Am, Im, Zum, and Zur": "am, im, zum እና zur",
    "War and Hatte": "war እና hatte",
    "Perfect Tense in Conversation": "Perfekt በውይይት ውስጥ",
    "Dative Case": "የDativ ኬዝ",
    "Two-Way Prepositions": "ባለሁለት አቅጣጫ መስተዋድዶች",
    "Adjective Endings after Articles": "ከአርቲክሎች በኋላ የቅጽል መጨረሻዎች",
    "Comparative and Superlative": "ንጽጽርና ከፍተኛ ደረጃ",
    "Reflexive Verbs": "ተመላሽ ግሶች",
    "Modal Verbs in the Past": "ሞዳል ግሶች ባለፈው ጊዜ",
    "Basic Relative Clauses": "መሠረታዊ የRelativsatz ሐረጎች",
    "Infinitive with Zu": "Infinitiv ከzu ጋር",
    "Indirect Questions": "ቀጥተኛ ያልሆኑ ጥያቄዎች",
    "Simple Past of Sein and Haben": "የsein እና haben ቀላል ያለፈ ጊዜ",
    "Verbs with Prepositions": "ከመስተዋድድ ጋር የሚመጡ ግሶች",
    "Purpose with Damit and Um...zu": "ዓላማን በdamit እና um...zu መግለጽ",
    "Forming Past Participles": "Partizip II መመስረት",
    "Reasons and Results": "ምክንያቶችና ውጤቶች",
    "Dative and Accusative Pronouns": "የDativ እና Akkusativ ተውላጠ ስሞች",
    "Man, Jemand, and Niemand": "man, jemand እና niemand",
    "Als, Wenn, Bevor, and Nachdem": "als, wenn, bevor እና nachdem",
    "Da- and Wo- Compounds": "በda- እና wo- የሚፈጠሩ ውህዶች",
    "Time, Manner, and Place": "ጊዜ፣ አኳኋንና ቦታ",
    "Ordering Two Objects": "ሁለት ኦብጀክቶችን ማስቀመጥ",
    "Reflexive Dative": "ተመላሽ Dativ",
    "Weak Masculine Nouns": "ደካማ የወንድ ፆታ ስሞች",
    "Changes with Werden": "በwerden የሚገለጹ ለውጦች",
    "Subordinate Clauses with Weil, Dass, Wenn": "ከweil, dass እና wenn ጋር የበታች ሐረጎች",
    "Narrating in the Past": "ባለፈው ጊዜ ታሪክ መናገር",
    "Relative Clauses in All Cases": "በሁሉም ኬዞች የRelativsatz ሐረጎች",
    "Present and Past Passive": "የአሁንና ያለፈ ጊዜ Passiv",
    "Genitive and Formal Possession": "Genitiv እና መደበኛ ባለቤትነት",
    "Adjective Endings without Articles": "ያለ አርቲክል የቅጽል መጨረሻዎች",
    "N-Declension Masculine Nouns": "N-Deklination የወንድ ፆታ ስሞች",
    "Participles as Adjectives": "አሳታፊ ቅርጾችን እንደ ቅጽል መጠቀም",
    "Nominalization": "ስማዊ አገላለጽ (Nominalisierung)",
    "Paired and Contrast Connectors": "ጥንድና ተቃርኖ አገናኞች",
    "Reporting Speech": "የሌላ ሰውን ንግግር ማስተላለፍ",
    "Future and Assumptions with Werden": "በwerden የወደፊት ጊዜና ግምቶች",
    "Concession with Obwohl and Trotzdem": "በobwohl እና trotzdem ተቃራኒ ሁኔታን መግለጽ",
    "Alternative Passive Forms": "አማራጭ የPassiv ቅርጾች",
    "Past Perfect in Narratives": "Plusquamperfekt በትረካ",
    "Precise Time Relationships": "ትክክለኛ የጊዜ ግንኙነቶች",
    "Real and Hypothetical Conditions": "እውነተኛና መላምታዊ ሁኔታዎች",
    "Ohne...zu and Statt...zu": "ohne...zu እና statt...zu",
    "Verb-Noun Collocations": "የግስና ስም ቋሚ ጥምረቶች",
    "Method and Result Clauses": "የአሰራርና ውጤት ሐረጎች",
    "Passive with Modal Verbs": "Passiv ከሞዳል ግሶች ጋር",
    "Relative Clauses with Wo and Was": "Relativsatz ከwo እና was ጋር",
    "Modal Particles in Conversation": "ሞዳል ቅንጣቶች በውይይት",
    "Richer Concessive Links": "የበለጠ የተራቀቁ ተቃርኖ አገናኞች",
    "Unreal Past Conditions": "እውን ያልሆኑ ያለፈ ጊዜ ሁኔታዎች",
    "Konjunktiv II for Polite Requests and Hypotheticals": "Konjunktiv II ለጨዋነት ጥያቄዎችና መላምቶች",
    "Beginner German": "ጀማሪ ጀርመንኛ",
    "Everyday German": "የዕለት ተዕለት ጀርመንኛ",
    "Independent German": "ራስን የቻለ ጀርመንኛ",
    "Build the foundations for everyday life": "ለዕለት ተዕለት ሕይወት መሠረቱን ይገንቡ",
    "Handle common situations with confidence": "የተለመዱ ሁኔታዎችን በራስ መተማመን ይቆጣጠሩ",
    "Express yourself clearly and prepare for the exam": "ሐሳብዎን በግልጽ ይግለጹ እና ለፈተናው ይዘጋጁ",
}

SWIFT_CALL_PATTERNS = [
    re.compile(r'TeachingText\s*\(\s*english:\s*"((?:\\.|[^"\\])*)"'),
    re.compile(r'TeachingLabel\s*\(\s*english:\s*"((?:\\.|[^"\\])*)"'),
    re.compile(r'TeachingButton\s*\(\s*"((?:\\.|[^"\\])*)"'),
    re.compile(r'\.teachingNavigationTitle\s*\(\s*"((?:\\.|[^"\\])*)"'),
    re.compile(r'\.teachingAccessibility(?:Label|Hint|Value)\s*\(\s*"((?:\\.|[^"\\])*)"'),
]
SWIFT_LITERAL_PATTERN = re.compile(r'"((?:\\.|[^"\\])*)"')

ENGLISH_SIGNAL_WORDS = {
    "about",
    "again",
    "answer",
    "available",
    "beginner",
    "build",
    "can",
    "chapter",
    "check",
    "choose",
    "complete",
    "continue",
    "correct",
    "course",
    "dative",
    "day",
    "everyday",
    "example",
    "explanation",
    "first",
    "german",
    "grammar",
    "hear",
    "i",
    "independent",
    "language",
    "learn",
    "lesson",
    "marked",
    "meaning",
    "memorized",
    "next",
    "practice",
    "question",
    "read",
    "ready",
    "recall",
    "repeat",
    "review",
    "sentence",
    "speak",
    "start",
    "this",
    "try",
    "understand",
    "word",
    "write",
    "you",
    "your",
}


def add_text(sources: set[str], value: object) -> None:
    if not isinstance(value, str):
        return
    cleaned = value.strip()
    if cleaned:
        sources.add(cleaned)


def add_many(sources: set[str], values: object) -> None:
    if isinstance(values, list):
        for value in values:
            add_text(sources, value)


def load_json(name: str) -> object:
    return json.loads((RESOURCE_DIR / f"{name}.json").read_text(encoding="utf-8"))


def collect_grammar(sources: set[str]) -> list[tuple[str, str]]:
    protected_prompts: list[tuple[str, str]] = []
    for topic in load_json("grammar"):
        add_text(sources, topic.get("title"))
        add_text(sources, topic.get("explanation"))
        add_many(sources, topic.get("commonMistakes"))
        for example in topic.get("examples", []):
            add_text(sources, example.get("english"))
        for item in topic.get("practice", []):
            prompt = item.get("prompt")
            answer = item.get("answer")
            add_text(sources, prompt)
            add_text(sources, item.get("explanation"))
            if isinstance(prompt, str) and isinstance(answer, str):
                protected_prompts.append((prompt, answer))
    return protected_prompts


def collect_lessons(sources: set[str]) -> list[tuple[str, str]]:
    protected_prompts: list[tuple[str, str]] = []
    for lesson in load_json("lessons"):
        add_text(sources, lesson.get("scenario"))
        for item in lesson.get("guidedPractice", []):
            prompt = item.get("prompt")
            answer = item.get("answer")
            add_text(sources, prompt)
            add_text(sources, item.get("explanation"))
            if isinstance(prompt, str) and isinstance(answer, str):
                protected_prompts.append((prompt, answer))
        listening = lesson.get("listening", {})
        for item in listening.get("questions", []):
            add_text(sources, item.get("prompt"))
            add_text(sources, item.get("answer"))
            add_text(sources, item.get("explanation"))
        speaking = lesson.get("speaking", {})
        add_text(sources, speaking.get("prompt"))
        writing = lesson.get("writing", {})
        add_text(sources, writing.get("prompt"))
        add_many(sources, writing.get("checklist"))
        add_many(sources, lesson.get("recap"))
    return protected_prompts


def collect_vocabulary(sources: set[str]) -> None:
    for name in ("vocab_a1", "vocab_a2", "vocab_b1"):
        for word in load_json(name):
            add_text(sources, word.get("english"))
            add_text(sources, word.get("exampleTranslation"))


def collect_phrasebook(sources: set[str]) -> None:
    for category in load_json("everyday_phrases"):
        add_text(sources, category.get("title"))
        add_text(sources, category.get("subtitle"))
        for phrase in category.get("phrases", []):
            add_text(sources, phrase.get("english"))


def collect_practical_missions(sources: set[str]) -> None:
    for mission in load_json("practical_missions"):
        for key in (
            "title",
            "setting",
            "partnerRole",
            "goal",
        ):
            add_text(sources, mission.get(key))
        add_many(sources, mission.get("canDo"))
        add_many(sources, mission.get("writingChecklist"))
        for phrase in mission.get("phrases", []):
            add_text(sources, phrase.get("english"))
        for turn in mission.get("turns", []):
            for key in ("cueTranslation", "responseTranslation"):
                add_text(sources, turn.get(key))


def collect_quizzes_and_exam(sources: set[str]) -> None:
    for item in load_json("quizzes"):
        add_text(sources, item.get("prompt"))
        add_text(sources, item.get("explanation"))

    exam = load_json("mock_exam_b1")
    if isinstance(exam, dict):
        add_text(sources, exam.get("title"))
        for section in exam.get("sections", []):
            add_text(sources, section.get("title"))
            add_text(sources, section.get("instructions"))
            for task in section.get("tasks", []):
                add_text(sources, task.get("prompt"))


def decode_swift_literal(value: str) -> str:
    return (
        value.replace(r"\"", '"')
        .replace(r"\n", "\n")
        .replace(r"\t", "\t")
        .replace(r"\\", "\\")
    )


def is_english_swift_text(value: str) -> bool:
    words = set(re.findall(r"[A-Za-z]+", value.lower()))
    return len(words & ENGLISH_SIGNAL_WORDS) > 0


def collect_swift_literals(sources: set[str]) -> None:
    for path in SOURCE_DIR.rglob("*.swift"):
        if "Tests" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        for pattern in SWIFT_CALL_PATTERNS:
            for match in pattern.finditer(text):
                value = decode_swift_literal(match.group(1))
                if "\\(" not in value and is_english_swift_text(value):
                    add_text(sources, value)
        for match in SWIFT_LITERAL_PATTERN.finditer(text):
            value = decode_swift_literal(match.group(1))
            if "\\(" not in value and is_english_swift_text(value):
                add_text(sources, value)


def looks_like_support_instruction(lower: str) -> bool:
    return any(
        lower.startswith(prefix)
        for prefix in (
            "what ",
            "which ",
            "why ",
            "how ",
            "where ",
            "when ",
            "choose ",
            "fill ",
            "build ",
            "reorder",
            "translate",
            "complete",
            "spell ",
            "formal ",
            "best ",
            "write ",
            "say ",
        )
    )


def protected_exercise_source(prompt: str, answer: str) -> str:
    protected: list[str] = []
    lower = prompt.lower()
    support_only_prefixes = ("translate:", "translate for ")

    if not any(lower.startswith(prefix) for prefix in support_only_prefixes) and ":" in prompt:
        tail = prompt.split(":", 1)[1].strip()
        if " (" in tail:
            tail = tail.split(" (", 1)[0]
        if tail:
            protected.append(tail)
    elif not looks_like_support_instruction(lower):
        protected.append(prompt)

    if answer and answer.casefold() in prompt.casefold():
        protected.append(answer)

    return protected_translation_source(prompt, explicit_german=protected)


def protected_translation_source(
    source: str, explicit_german: list[str] | None = None
) -> str:
    segments: list[str] = []
    for candidate in explicit_german or []:
        cleaned = candidate.strip()
        if not cleaned:
            continue
        if re.fullmatch(r"[^\W_]+", cleaned):
            match = re.search(
                rf"(?<!\w){re.escape(cleaned)}(?!\w)",
                source,
                flags=re.IGNORECASE,
            )
            if match:
                segments.append(match.group(0))
        elif cleaned in source:
            segments.append(cleaned)
    for term in PROTECTED_GERMAN_TERMS:
        pattern = rf"(?<!\w){re.escape(term)}(?!\w)"
        segments.extend(
            match.group(0)
            for match in re.finditer(pattern, source, flags=re.IGNORECASE)
        )
    segments.extend(quoted_german_segments(source))

    matching = {segment.strip() for segment in segments if segment.strip()}
    masked = source
    token_index = 0
    for german in sorted(matching, key=lambda item: (-len(item), item)):
        masked, replacement_count = replace_exact_segment(
            masked, german, f"ZXQGERMAN{token_index}QXZ"
        )
        if replacement_count:
            token_index += 1
    return masked


def replace_exact_segment(source: str, segment: str, replacement: str) -> tuple[str, int]:
    if re.fullmatch(r"[^\W_]+", segment):
        return re.subn(
            rf"(?<!\w){re.escape(segment)}(?!\w)",
            replacement,
            source,
        )
    count = source.count(segment)
    return source.replace(segment, replacement), count


def quoted_german_segments(source: str) -> list[str]:
    return [
        match.group(0)
        for match in re.finditer(r"“([^”]+)”", source)
        if looks_like_german(match.group(1))
    ]


def looks_like_german(value: str) -> bool:
    if re.search(r"[äöüÄÖÜß]", value):
        return True
    signals = PROTECTED_GERMAN_TERMS + [
        "ist", "sind", "bin", "bist", "hat", "habe", "hast",
        "kann", "können", "muss", "müssen", "wird", "würde",
        "mit", "für", "auf", "zu", "im", "am", "von", "nach",
        "und", "aber", "oder", "auch",
    ]
    if any(
        re.search(rf"(?<!\w){re.escape(term)}(?!\w)", value, flags=re.IGNORECASE)
        for term in signals
    ):
        return True
    return " " not in value and value[:1].isupper()


def collect_sources() -> list[str]:
    sources: set[str] = set()
    sources.update(REQUIRED_MICROCOPY_SOURCES)
    protected_prompts = collect_grammar(sources)
    protected_prompts.extend(collect_lessons(sources))
    collect_vocabulary(sources)
    collect_phrasebook(sources)
    collect_practical_missions(sources)
    collect_quizzes_and_exam(sources)
    collect_swift_literals(sources)
    generated_curriculum = ROOT / "Tools" / "generated_curriculum_sources.json"
    if generated_curriculum.exists():
        add_many(
            sources,
            json.loads(generated_curriculum.read_text(encoding="utf-8")),
        )

    for prompt, answer in protected_prompts:
        add_text(sources, protected_exercise_source(prompt, answer))

    for source in list(sources):
        add_text(sources, protected_translation_source(source))

    return sorted(sources, key=lambda item: (len(item), item.casefold()))


def batches(values: list[str]) -> list[list[str]]:
    result: list[list[str]] = []
    current: list[str] = []
    character_count = 0
    for value in values:
        projected = character_count + len(value) + 32
        if current and (
            len(current) >= MAX_BATCH_ITEMS or projected > MAX_BATCH_CHARACTERS
        ):
            result.append(current)
            current = []
            character_count = 0
        current.append(value)
        character_count += len(value) + 32
    if current:
        result.append(current)
    return result


def request_translation(source_batch: list[str], target_language: str) -> list[str]:
    markers = [f"ZXQAMHSEP{index:03d}QXZ" for index in range(len(source_batch) - 1)]
    parts: list[str] = []
    for index, source in enumerate(source_batch):
        parts.append(source)
        if index < len(markers):
            parts.append(markers[index])
    payload = "\n".join(parts)
    query = urllib.parse.urlencode(
        {
            "client": "gtx",
            "sl": "en",
            "tl": target_language,
            "dt": "t",
            "q": payload,
        }
    )
    request = urllib.request.Request(
        f"{TRANSLATE_URL}?{query}",
        headers={"User-Agent": "DeutschB1Coach-Curriculum-Localization/1.0"},
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        data = json.load(response)
    translated = "".join(segment[0] for segment in data[0])
    split_pattern = r"\s*ZXQAMHSEP\d{3}QXZ\s*"
    results = [part.strip() for part in re.split(split_pattern, translated)]
    if len(results) != len(source_batch):
        raise ValueError(
            f"Translation separator mismatch: expected {len(source_batch)}, got {len(results)}"
        )
    return results


def german_tokens(value: str) -> list[str]:
    return GERMAN_TOKEN_PATTERN.findall(value)


def has_exact_german_tokens(source: str, target: str) -> bool:
    return sorted(token.casefold() for token in german_tokens(source)) == sorted(
        token.casefold() for token in german_tokens(target)
    )


def translate_preserving_german(source: str, target_language: str) -> str:
    parts = GERMAN_TOKEN_PATTERN.split(source)
    translatable: list[tuple[int, str, str]] = []
    for index, part in enumerate(parts):
        if not part or GERMAN_TOKEN_PATTERN.fullmatch(part):
            continue
        match = re.fullmatch(r"(\s*)(.*?)(\s*)", part, flags=re.DOTALL)
        if not match or not re.search(r"[A-Za-z]", match.group(2)):
            continue
        translatable.append((index, match.group(1), match.group(3)))
    if not translatable:
        return source
    translated_parts: list[str] = []
    values = [parts[index].strip() for index, _, _ in translatable]
    for value_batch in batches(values):
        translated_parts.extend(request_translation(value_batch, target_language))
    for (index, leading, trailing), translated in zip(
        translatable, translated_parts, strict=True
    ):
        parts[index] = f"{leading}{translated}{trailing}"
    return "".join(parts)


def translate_all(
    sources: list[str], output: Path, target_language: str
) -> dict[str, str]:
    existing: dict[str, str] = {}
    if output.exists():
        existing = json.loads(output.read_text(encoding="utf-8"))

    damaged = [
        source
        for source in sources
        if german_tokens(source)
        and existing.get(source)
        and not has_exact_german_tokens(source, existing[source])
    ]
    for source in damaged:
        existing.pop(source, None)

    missing = [source for source in sources if not existing.get(source, "").strip()]
    work = batches(missing)
    print(
        f"{len(sources)} curriculum strings, {len(existing)} cached, "
        f"{len(missing)} to translate in {len(work)} batches"
        f" ({len(damaged)} damaged German boundaries will be repaired)."
    )

    for batch_index, source_batch in enumerate(work, start=1):
        for attempt in range(1, 5):
            try:
                targets = request_translation(source_batch, target_language)
                break
            except Exception as error:
                if attempt == 4:
                    raise RuntimeError(
                        f"Batch {batch_index} failed after {attempt} attempts"
                    ) from error
                time.sleep(attempt * 1.5)

        for source, target in zip(source_batch, targets, strict=True):
            if german_tokens(source) and not has_exact_german_tokens(source, target):
                target = translate_preserving_german(source, target_language)
            if target:
                existing[source] = target

        if batch_index % 10 == 0 or batch_index == len(work):
            output.write_text(
                json.dumps(existing, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                encoding="utf-8",
            )
            print(f"Translated batch {batch_index}/{len(work)}")
        time.sleep(0.08)

    if target_language == DEFAULT_LANGUAGE:
        existing.update(MANUAL_OVERRIDES)
    output.write_text(
        json.dumps(existing, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return existing


def validate(
    sources: list[str], translations: dict[str, str], target_language: str
) -> None:
    missing = [source for source in sources if not translations.get(source, "").strip()]
    unchanged = [
        source
        for source in sources
        if translations.get(source, "").strip().casefold() == source.casefold()
        and re.search(r"[A-Za-z]{3,}", source)
    ]
    if missing:
        raise RuntimeError(f"{len(missing)} source strings have no translation")
    damaged = [
        source
        for source in sources
        if german_tokens(source)
        and not has_exact_german_tokens(source, translations.get(source, ""))
    ]
    if damaged:
        raise RuntimeError(
            f"{len(damaged)} translations do not preserve their exact German content"
        )
    if unchanged:
        print(f"Warning: {len(unchanged)} translations are unchanged.")
    print(f"Validated {len(sources)} bundled {target_language} translations.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--language", default=DEFAULT_LANGUAGE)
    parser.add_argument("--output", type=Path)
    parser.add_argument(
        "--core-only",
        action="store_true",
        help="Translate only the shared course labels shown before dynamic content loads.",
    )
    arguments = parser.parse_args()
    output = arguments.output or RESOURCE_DIR / f"{arguments.language}_translations.json"
    sources = CORE_INTERFACE_SOURCES if arguments.core_only else collect_sources()
    translations = translate_all(sources, output, arguments.language)
    validate(sources, translations, arguments.language)


if __name__ == "__main__":
    main()
