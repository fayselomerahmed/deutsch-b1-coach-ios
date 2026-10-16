import Foundation

enum TeachingLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case amharic = "am"
    case arabic = "ar"
    case simplifiedChinese = "zh-Hans"
    case dutch = "nl"
    case french = "fr"
    case hindi = "hi"
    case indonesian = "id"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case polish = "pl"
    case portuguese = "pt"
    case russian = "ru"
    case spanish = "es"
    case thai = "th"
    case tigrinya = "ti"
    case turkish = "tr"
    case ukrainian = "uk"
    case vietnamese = "vi"

    static let storageKey = "teachingLanguage"
    static let defaultLanguage = TeachingLanguage.english

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .english: "English"
        case .amharic: "አማርኛ"
        case .arabic: "العربية"
        case .simplifiedChinese: "简体中文"
        case .dutch: "Nederlands"
        case .french: "Français"
        case .hindi: "हिन्दी"
        case .indonesian: "Bahasa Indonesia"
        case .italian: "Italiano"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .polish: "Polski"
        case .portuguese: "Português"
        case .russian: "Русский"
        case .spanish: "Español"
        case .thai: "ไทย"
        case .tigrinya: "ትግርኛ"
        case .turkish: "Türkçe"
        case .ukrainian: "Українська"
        case .vietnamese: "Tiếng Việt"
        }
    }

    var englishName: String {
        switch self {
        case .english: "English"
        case .amharic: "Amharic"
        case .arabic: "Arabic"
        case .simplifiedChinese: "Chinese (Simplified)"
        case .dutch: "Dutch"
        case .french: "French"
        case .hindi: "Hindi"
        case .indonesian: "Indonesian"
        case .italian: "Italian"
        case .japanese: "Japanese"
        case .korean: "Korean"
        case .polish: "Polish"
        case .portuguese: "Portuguese"
        case .russian: "Russian"
        case .spanish: "Spanish"
        case .thai: "Thai"
        case .tigrinya: "Tigrinya"
        case .turkish: "Turkish"
        case .ukrainian: "Ukrainian"
        case .vietnamese: "Vietnamese"
        }
    }

    var pickerName: String {
        englishName == nativeName ? nativeName : "\(nativeName) · \(englishName)"
    }

    var flag: String {
        switch self {
        case .english: "🇬🇧"
        case .amharic: "🇪🇹"
        case .arabic: "🇸🇦"
        case .simplifiedChinese: "🇨🇳"
        case .dutch: "🇳🇱"
        case .french: "🇫🇷"
        case .hindi: "🇮🇳"
        case .indonesian: "🇮🇩"
        case .italian: "🇮🇹"
        case .japanese: "🇯🇵"
        case .korean: "🇰🇷"
        case .polish: "🇵🇱"
        case .portuguese: "🇵🇹"
        case .russian: "🇷🇺"
        case .spanish: "🇪🇸"
        case .thai: "🇹🇭"
        case .tigrinya: "🇪🇷"
        case .turkish: "🇹🇷"
        case .ukrainian: "🇺🇦"
        case .vietnamese: "🇻🇳"
        }
    }

    var flaggedPickerName: String {
        "\(flag) \(pickerName)"
    }

    var toolbarCode: String {
        String(rawValue.prefix(2)).uppercased()
    }

    var isRightToLeft: Bool { self == .arabic }
    var usesBundledExplanations: Bool { self != .english }

    var bundledExplanationStatus: String? {
        switch self {
        case .english: nil
        default: "\(nativeName) ✓"
        }
    }

    static func resolve(_ rawValue: String) -> TeachingLanguage {
        TeachingLanguage(rawValue: rawValue) ?? defaultLanguage
    }

    func interfaceText(_ key: TeachingInterfaceKey) -> String {
        let values: [TeachingInterfaceKey: String]
        switch self {
        case .english:
            values = [
                .home: "Home", .learn: "Learn", .practice: "Practice", .review: "Review",
                .progress: "Progress", .settings: "Settings", .done: "Done",
                .continueAction: "Continue", .startFromA1: "Start from A1",
                .teachingLanguage: "Teaching language", .course: "Course", .library: "Library",
                .orientation: "Orientation"
            ]
        case .amharic:
            values = [
                .home: "መነሻ", .learn: "መማር", .practice: "ልምምድ", .review: "ክለሳ",
                .progress: "እድገት", .settings: "ቅንብሮች", .done: "ጨርስ",
                .continueAction: "ቀጥል", .startFromA1: "ከA1 ጀምር",
                .teachingLanguage: "የማብራሪያ ቋንቋ", .course: "ኮርስ", .library: "ቤተ መጻሕፍት",
                .orientation: "የአቅጣጫ ትምህርት"
            ]
        case .arabic:
            values = [
                .home: "الرئيسية", .learn: "تعلّم", .practice: "تدرّب", .review: "مراجعة",
                .progress: "التقدم", .settings: "الإعدادات", .done: "تم",
                .continueAction: "متابعة", .startFromA1: "ابدأ من A1",
                .teachingLanguage: "لغة الشرح", .course: "الدورة", .library: "المكتبة",
                .orientation: "التوجيه"
            ]
        case .simplifiedChinese:
            values = [
                .home: "首页", .learn: "学习", .practice: "练习", .review: "复习",
                .progress: "进度", .settings: "设置", .done: "完成",
                .continueAction: "继续", .startFromA1: "从 A1 开始",
                .teachingLanguage: "教学语言", .course: "课程", .library: "资料库",
                .orientation: "入籍常识"
            ]
        case .dutch:
            values = [
                .home: "Home", .learn: "Leren", .practice: "Oefenen", .review: "Herhalen",
                .progress: "Voortgang", .settings: "Instellingen", .done: "Klaar",
                .continueAction: "Doorgaan", .startFromA1: "Begin bij A1",
                .teachingLanguage: "Uitlegtaal", .course: "Cursus", .library: "Bibliotheek",
                .orientation: "Oriëntatie"
            ]
        case .french:
            values = [
                .home: "Accueil", .learn: "Apprendre", .practice: "Pratiquer", .review: "Réviser",
                .progress: "Progrès", .settings: "Réglages", .done: "Terminé",
                .continueAction: "Continuer", .startFromA1: "Commencer au niveau A1",
                .teachingLanguage: "Langue d’explication", .course: "Cours", .library: "Bibliothèque",
                .orientation: "Orientation"
            ]
        case .hindi:
            values = [
                .home: "होम", .learn: "सीखें", .practice: "अभ्यास", .review: "दोहराएँ",
                .progress: "प्रगति", .settings: "सेटिंग्स", .done: "पूरा हुआ",
                .continueAction: "जारी रखें", .startFromA1: "A1 से शुरू करें",
                .teachingLanguage: "समझाने की भाषा", .course: "पाठ्यक्रम", .library: "पुस्तकालय",
                .orientation: "अभिमुखीकरण"
            ]
        case .indonesian:
            values = [
                .home: "Beranda", .learn: "Belajar", .practice: "Latihan", .review: "Ulangi",
                .progress: "Kemajuan", .settings: "Pengaturan", .done: "Selesai",
                .continueAction: "Lanjutkan", .startFromA1: "Mulai dari A1",
                .teachingLanguage: "Bahasa pengantar", .course: "Kursus", .library: "Perpustakaan",
                .orientation: "Orientasi"
            ]
        case .italian:
            values = [
                .home: "Home", .learn: "Impara", .practice: "Esercitati", .review: "Ripassa",
                .progress: "Progressi", .settings: "Impostazioni", .done: "Fatto",
                .continueAction: "Continua", .startFromA1: "Inizia da A1",
                .teachingLanguage: "Lingua delle spiegazioni", .course: "Corso", .library: "Biblioteca",
                .orientation: "Orientamento"
            ]
        case .japanese:
            values = [
                .home: "ホーム", .learn: "学ぶ", .practice: "練習", .review: "復習",
                .progress: "進捗", .settings: "設定", .done: "完了",
                .continueAction: "続ける", .startFromA1: "A1 から始める",
                .teachingLanguage: "解説言語", .course: "コース", .library: "ライブラリ",
                .orientation: "オリエンテーション"
            ]
        case .korean:
            values = [
                .home: "홈", .learn: "학습", .practice: "연습", .review: "복습",
                .progress: "진행 상황", .settings: "설정", .done: "완료",
                .continueAction: "계속", .startFromA1: "A1부터 시작",
                .teachingLanguage: "설명 언어", .course: "코스", .library: "학습 자료",
                .orientation: "오리엔테이션"
            ]
        case .polish:
            values = [
                .home: "Start", .learn: "Nauka", .practice: "Ćwiczenia", .review: "Powtórki",
                .progress: "Postępy", .settings: "Ustawienia", .done: "Gotowe",
                .continueAction: "Kontynuuj", .startFromA1: "Zacznij od A1",
                .teachingLanguage: "Język objaśnień", .course: "Kurs", .library: "Biblioteka",
                .orientation: "Orientacja"
            ]
        case .portuguese:
            values = [
                .home: "Início", .learn: "Aprender", .practice: "Praticar", .review: "Revisar",
                .progress: "Progresso", .settings: "Ajustes", .done: "Concluído",
                .continueAction: "Continuar", .startFromA1: "Começar no A1",
                .teachingLanguage: "Idioma das explicações", .course: "Curso", .library: "Biblioteca",
                .orientation: "Orientação"
            ]
        case .russian:
            values = [
                .home: "Главная", .learn: "Учиться", .practice: "Практика", .review: "Повторение",
                .progress: "Прогресс", .settings: "Настройки", .done: "Готово",
                .continueAction: "Продолжить", .startFromA1: "Начать с A1",
                .teachingLanguage: "Язык объяснений", .course: "Курс", .library: "Библиотека",
                .orientation: "Ориентация"
            ]
        case .spanish:
            values = [
                .home: "Inicio", .learn: "Aprender", .practice: "Practicar", .review: "Repasar",
                .progress: "Progreso", .settings: "Ajustes", .done: "Listo",
                .continueAction: "Continuar", .startFromA1: "Empezar desde A1",
                .teachingLanguage: "Idioma de explicación", .course: "Curso", .library: "Biblioteca",
                .orientation: "Orientación"
            ]
        case .thai:
            values = [
                .home: "หน้าหลัก", .learn: "เรียน", .practice: "ฝึก", .review: "ทบทวน",
                .progress: "ความคืบหน้า", .settings: "การตั้งค่า", .done: "เสร็จแล้ว",
                .continueAction: "ดำเนินการต่อ", .startFromA1: "เริ่มจาก A1",
                .teachingLanguage: "ภาษาคำอธิบาย", .course: "หลักสูตร", .library: "คลังบทเรียน",
                .orientation: "ปฐมนิเทศ"
            ]
        case .tigrinya:
            values = [
                .home: "ቀንዲ ገጽ", .learn: "ምምሃር", .practice: "ልምምድ", .review: "ክለሳ",
                .progress: "ምዕባለ", .settings: "ቅንብራት", .done: "ወዲእካ",
                .continueAction: "ቀጽል", .startFromA1: "ካብ A1 ጀምር",
                .teachingLanguage: "ቋንቋ መብርሂ", .course: "ኮርስ", .library: "ቤተ መጻሕፍቲ",
                .orientation: "ኦርየንቴሽን"
            ]
        case .turkish:
            values = [
                .home: "Ana Sayfa", .learn: "Öğren", .practice: "Alıştırma", .review: "Tekrar",
                .progress: "İlerleme", .settings: "Ayarlar", .done: "Bitti",
                .continueAction: "Devam", .startFromA1: "A1’den başla",
                .teachingLanguage: "Anlatım dili", .course: "Kurs", .library: "Kütüphane",
                .orientation: "Uyum"
            ]
        case .ukrainian:
            values = [
                .home: "Головна", .learn: "Навчання", .practice: "Практика", .review: "Повторення",
                .progress: "Прогрес", .settings: "Налаштування", .done: "Готово",
                .continueAction: "Продовжити", .startFromA1: "Почати з A1",
                .teachingLanguage: "Мова пояснень", .course: "Курс", .library: "Бібліотека",
                .orientation: "Орієнтація"
            ]
        case .vietnamese:
            values = [
                .home: "Trang chủ", .learn: "Học", .practice: "Luyện tập", .review: "Ôn tập",
                .progress: "Tiến độ", .settings: "Cài đặt", .done: "Xong",
                .continueAction: "Tiếp tục", .startFromA1: "Bắt đầu từ A1",
                .teachingLanguage: "Ngôn ngữ giải thích", .course: "Khóa học", .library: "Thư viện",
                .orientation: "Định hướng"
            ]
        }
        return values[key] ?? TeachingLanguage.english.interfaceText(key)
    }
}

enum TeachingInterfaceKey: CaseIterable {
    case home
    case learn
    case practice
    case review
    case progress
    case settings
    case done
    case continueAction
    case startFromA1
    case teachingLanguage
    case course
    case library
    case orientation
}
