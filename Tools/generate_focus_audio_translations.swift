import Foundation

private let sources = [
    "Vocabulary",
    "Listening",
    "Reading",
    "Writing",
    "Speaking",
    "Where do you need the most help?",
    "Choose one focus. Your practice will adapt, and you can change it later.",
    "Learning focus",
    "Your focused path",
    "Practice the skill that needs the most attention",
    "My focus",
    "Change focus",
    "Start focused practice",
    "Playback speed",
    "Cancel German audio",
    "Pause German audio",
    "Resume German audio",
    "Stop German audio",
    "More improvements for you",
]

private let catalogFiles = [
    "am": "amharic_translations.json",
    "ar": "ar_translations.json",
    "zh-Hans": "zh-Hans_translations.json",
    "nl": "nl_translations.json",
    "fr": "fr_translations.json",
    "hi": "hi_translations.json",
    "id": "id_translations.json",
    "it": "it_translations.json",
    "ja": "ja_translations.json",
    "ko": "ko_translations.json",
    "pl": "pl_translations.json",
    "pt": "pt_translations.json",
    "ru": "ru_translations.json",
    "es": "es_translations.json",
    "th": "th_translations.json",
    "ti": "ti_translations.json",
    "tr": "tr_translations.json",
    "uk": "uk_translations.json",
    "vi": "vi_translations.json",
]

private let translations: [String: [String]] = [
    "am": [
        "የቃላት ክምችት", "ማዳመጥ", "ማንበብ", "መጻፍ", "መናገር",
        "በጣም እርዳታ የሚያስፈልግዎት የት ነው?",
        "አንድ ትኩረት ይምረጡ። ልምምድዎ ይስማማል፣ እና በኋላ መቀየር ይችላሉ።",
        "የመማር ትኩረት", "የእርስዎ የትኩረት መንገድ",
        "በጣም ትኩረት የሚፈልገውን ክህሎት ይለማመዱ", "የእኔ ትኩረት", "ትኩረትን ቀይር",
        "የትኩረት ልምምድ ጀምር", "የመልሶ ማጫወት ፍጥነት", "የጀርመንኛ ድምፅን ሰርዝ",
        "የጀርመንኛ ድምፅን ለአፍታ አቁም", "የጀርመንኛ ድምፅን ቀጥል", "የጀርመንኛ ድምፅን አቁም", "ለእርስዎ ተጨማሪ ማሻሻያዎች",
    ],
    "ar": [
        "المفردات", "الاستماع", "القراءة", "الكتابة", "التحدث",
        "أين تحتاج إلى أكبر قدر من المساعدة؟",
        "اختر مجالًا واحدًا للتركيز. سيتكيف تدريبك معه، ويمكنك تغييره لاحقًا.",
        "محور التعلم", "مسارك المركّز", "تدرّب على المهارة التي تحتاج إلى أكبر قدر من الاهتمام",
        "محور تركيزي", "تغيير محور التركيز", "بدء التدريب المركّز", "سرعة التشغيل",
        "إلغاء الصوت الألماني", "إيقاف الصوت الألماني مؤقتًا", "استئناف الصوت الألماني", "إيقاف الصوت الألماني", "تحسينات إضافية لك",
    ],
    "zh-Hans": [
        "词汇", "听力", "阅读", "写作", "口语",
        "你最需要哪方面的帮助？", "请选择一个重点。练习内容会随之调整，你之后也可以更改。",
        "学习重点", "你的重点学习路径", "练习最需要加强的技能", "我的重点", "更改重点",
        "开始重点练习", "播放速度", "取消德语音频", "暂停德语音频", "继续播放德语音频", "停止德语音频", "更多适合你的提升练习",
    ],
    "nl": [
        "Woordenschat", "Luisteren", "Lezen", "Schrijven", "Spreken",
        "Waar heb je de meeste hulp bij nodig?",
        "Kies één aandachtspunt. Je oefeningen passen zich aan en je kunt het later wijzigen.",
        "Leerfocus", "Jouw gerichte leerpad", "Oefen de vaardigheid die de meeste aandacht nodig heeft",
        "Mijn focus", "Focus wijzigen", "Gericht oefenen starten", "Afspeelsnelheid",
        "Duitse audio annuleren", "Duitse audio pauzeren", "Duitse audio hervatten", "Duitse audio stoppen", "Meer verbeteringen voor jou",
    ],
    "fr": [
        "Vocabulaire", "Écoute", "Lecture", "Écriture", "Expression orale",
        "Où avez-vous le plus besoin d’aide ?",
        "Choisissez un axe prioritaire. Vos exercices s’adapteront et vous pourrez le modifier plus tard.",
        "Priorité d’apprentissage", "Votre parcours ciblé", "Entraînez la compétence qui demande le plus d’attention",
        "Ma priorité", "Changer de priorité", "Commencer l’entraînement ciblé", "Vitesse de lecture",
        "Annuler l’audio allemand", "Mettre l’audio allemand en pause", "Reprendre l’audio allemand", "Arrêter l’audio allemand", "D’autres progrès pour vous",
    ],
    "hi": [
        "शब्दावली", "सुनना", "पढ़ना", "लिखना", "बोलना",
        "आपको सबसे अधिक मदद किस क्षेत्र में चाहिए?",
        "एक कौशल चुनें। आपका अभ्यास उसी के अनुसार ढलेगा और आप इसे बाद में बदल सकते हैं।",
        "सीखने का मुख्य क्षेत्र", "आपका केंद्रित सीखने का मार्ग", "उस कौशल का अभ्यास करें जिस पर सबसे अधिक ध्यान चाहिए",
        "मेरा मुख्य क्षेत्र", "मुख्य क्षेत्र बदलें", "केंद्रित अभ्यास शुरू करें", "प्लेबैक गति",
        "जर्मन ऑडियो रद्द करें", "जर्मन ऑडियो को विराम दें", "जर्मन ऑडियो फिर चलाएँ", "जर्मन ऑडियो बंद करें", "आपके लिए और सुधार",
    ],
    "id": [
        "Kosakata", "Menyimak", "Membaca", "Menulis", "Berbicara",
        "Di bagian mana Anda paling membutuhkan bantuan?",
        "Pilih satu fokus. Latihan Anda akan menyesuaikan dan dapat diubah nanti.",
        "Fokus belajar", "Jalur belajar terfokus Anda", "Latih keterampilan yang paling membutuhkan perhatian",
        "Fokus saya", "Ubah fokus", "Mulai latihan terfokus", "Kecepatan pemutaran",
        "Batalkan audio bahasa Jerman", "Jeda audio bahasa Jerman", "Lanjutkan audio bahasa Jerman", "Hentikan audio bahasa Jerman", "Peningkatan lainnya untuk Anda",
    ],
    "it": [
        "Vocabolario", "Ascolto", "Lettura", "Scrittura", "Parlato",
        "In quale area hai più bisogno di aiuto?",
        "Scegli un’area su cui concentrarti. La pratica si adatterà e potrai cambiarla in seguito.",
        "Obiettivo di apprendimento", "Il tuo percorso mirato", "Esercita l’abilità che richiede più attenzione",
        "Il mio obiettivo", "Cambia obiettivo", "Inizia la pratica mirata", "Velocità di riproduzione",
        "Annulla audio in tedesco", "Metti in pausa l’audio in tedesco", "Riprendi l’audio in tedesco", "Interrompi l’audio in tedesco", "Altri miglioramenti per te",
    ],
    "ja": [
        "語彙", "リスニング", "読解", "ライティング", "スピーキング",
        "どの分野でいちばんサポートが必要ですか？",
        "重点分野を1つ選んでください。練習内容がそれに合わせて調整され、後から変更できます。",
        "学習の重点", "あなたの重点学習コース", "最も強化が必要なスキルを練習",
        "重点分野", "重点を変更", "重点練習を開始", "再生速度",
        "ドイツ語音声をキャンセル", "ドイツ語音声を一時停止", "ドイツ語音声を再開", "ドイツ語音声を停止", "さらに上達するために",
    ],
    "ko": [
        "어휘", "듣기", "읽기", "쓰기", "말하기",
        "어떤 영역에서 가장 도움이 필요한가요?",
        "집중할 영역을 하나 선택하세요. 연습 내용이 이에 맞게 조정되며 나중에 변경할 수 있습니다.",
        "학습 집중 영역", "나의 맞춤 학습 경로", "가장 보완이 필요한 능력을 연습하세요",
        "나의 집중 영역", "집중 영역 변경", "집중 연습 시작", "재생 속도",
        "독일어 오디오 취소", "독일어 오디오 일시 정지", "독일어 오디오 다시 재생", "독일어 오디오 중지", "더 향상할 수 있는 연습",
    ],
    "pl": [
        "Słownictwo", "Słuchanie", "Czytanie", "Pisanie", "Mówienie",
        "W czym potrzebujesz najwięcej pomocy?",
        "Wybierz jeden obszar. Ćwiczenia dostosują się do niego, a później możesz go zmienić.",
        "Główny obszar nauki", "Twoja ukierunkowana ścieżka", "Ćwicz umiejętność, która wymaga najwięcej uwagi",
        "Mój obszar", "Zmień obszar", "Rozpocznij ukierunkowane ćwiczenia", "Prędkość odtwarzania",
        "Anuluj niemieckie nagranie", "Wstrzymaj niemieckie nagranie", "Wznów niemieckie nagranie", "Zatrzymaj niemieckie nagranie", "Więcej możliwości poprawy",
    ],
    "pt": [
        "Vocabulário", "Compreensão oral", "Leitura", "Escrita", "Fala",
        "Em que área você mais precisa de ajuda?",
        "Escolha um foco. A prática será adaptada, e você poderá alterá-lo depois.",
        "Foco de aprendizagem", "Seu percurso focado", "Pratique a habilidade que mais precisa de atenção",
        "Meu foco", "Alterar foco", "Iniciar prática focada", "Velocidade de reprodução",
        "Cancelar áudio em alemão", "Pausar áudio em alemão", "Retomar áudio em alemão", "Parar áudio em alemão", "Mais melhorias para você",
    ],
    "ru": [
        "Словарный запас", "Аудирование", "Чтение", "Письмо", "Говорение",
        "В чём вам нужна наибольшая помощь?",
        "Выберите одно направление. Практика подстроится под него, и позже его можно изменить.",
        "Основное направление обучения", "Ваш целевой путь", "Тренируйте навык, которому нужно уделить больше всего внимания",
        "Мой фокус", "Изменить фокус", "Начать целевую практику", "Скорость воспроизведения",
        "Отменить немецкое аудио", "Приостановить немецкое аудио", "Продолжить немецкое аудио", "Остановить немецкое аудио", "Дополнительные улучшения для вас",
    ],
    "es": [
        "Vocabulario", "Comprensión auditiva", "Lectura", "Escritura", "Expresión oral",
        "¿En qué necesitas más ayuda?",
        "Elige un área principal. La práctica se adaptará y podrás cambiarla más adelante.",
        "Área principal de aprendizaje", "Tu ruta personalizada", "Practica la habilidad que necesita más atención",
        "Mi área principal", "Cambiar área principal", "Iniciar práctica personalizada", "Velocidad de reproducción",
        "Cancelar audio en alemán", "Pausar audio en alemán", "Reanudar audio en alemán", "Detener audio en alemán", "Más mejoras para ti",
    ],
    "th": [
        "คำศัพท์", "การฟัง", "การอ่าน", "การเขียน", "การพูด",
        "คุณต้องการความช่วยเหลือด้านใดมากที่สุด",
        "เลือกหนึ่งด้านที่ต้องการเน้น แบบฝึกหัดจะปรับให้เหมาะสม และคุณเปลี่ยนได้ภายหลัง",
        "จุดเน้นการเรียน", "เส้นทางการเรียนเฉพาะด้านของคุณ", "ฝึกทักษะที่ต้องการการพัฒนามากที่สุด",
        "จุดเน้นของฉัน", "เปลี่ยนจุดเน้น", "เริ่มฝึกแบบเน้นทักษะ", "ความเร็วการเล่น",
        "ยกเลิกเสียงภาษาเยอรมัน", "หยุดเสียงภาษาเยอรมันชั่วคราว", "เล่นเสียงภาษาเยอรมันต่อ", "หยุดเสียงภาษาเยอรมัน", "พัฒนาทักษะของคุณเพิ่มเติม",
    ],
    "ti": [
        "ቃላት", "ምስማዕ", "ምንባብ", "ምጽሓፍ", "ምዝራብ",
        "ኣበየናይ ክፍሊ ኢኻ ዝያዳ ሓገዝ እትደሊ?",
        "ሓደ ትኹረት ምረጽ። ልምምድካ ብእኡ ክስማማዕ እዩ፣ ድሕሪኡ ድማ ክትቅይሮ ትኽእል።",
        "ትኹረት ትምህርቲ", "ናትካ ዝተተኮረ መንገዲ", "እቲ ዝያዳ ትኹረት ዘድልዮ ክእለት ተለማመድ",
        "ትኹረተይ", "ትኹረት ቀይር", "ዝተተኮረ ልምምድ ጀምር", "ፍጥነት መጻወቲ",
        "ድምጺ ጀርመን ሰርዝ", "ድምጺ ጀርመን ንግዚኡ ደው ኣብል", "ድምጺ ጀርመን ቀጽል", "ድምጺ ጀርመን ኣቋርጽ", "ተወሳኺ ምምሕያሻት ንዓኻ",
    ],
    "tr": [
        "Kelime bilgisi", "Dinleme", "Okuma", "Yazma", "Konuşma",
        "En çok hangi konuda yardıma ihtiyacınız var?",
        "Bir odak alanı seçin. Alıştırmalarınız buna göre uyarlanır ve daha sonra değiştirebilirsiniz.",
        "Öğrenme odağı", "Odaklanmış öğrenme yolunuz", "En çok ilgi gerektiren beceriyi çalışın",
        "Odağım", "Odağı değiştir", "Odaklı alıştırmayı başlat", "Oynatma hızı",
        "Almanca sesi iptal et", "Almanca sesi duraklat", "Almanca sesi sürdür", "Almanca sesi durdur", "Sizin için daha fazla gelişim",
    ],
    "uk": [
        "Словниковий запас", "Аудіювання", "Читання", "Письмо", "Говоріння",
        "У чому вам найбільше потрібна допомога?",
        "Виберіть один напрям. Вправи підлаштуються під нього, а згодом його можна змінити.",
        "Основний напрям навчання", "Ваш цільовий шлях", "Тренуйте навичку, якій потрібно приділити найбільше уваги",
        "Мій напрям", "Змінити напрям", "Почати цільову практику", "Швидкість відтворення",
        "Скасувати аудіо німецькою", "Призупинити аудіо німецькою", "Продовжити аудіо німецькою", "Зупинити аудіо німецькою", "Додаткові покращення для вас",
    ],
    "vi": [
        "Từ vựng", "Nghe", "Đọc", "Viết", "Nói",
        "Bạn cần được hỗ trợ nhiều nhất ở kỹ năng nào?",
        "Chọn một kỹ năng trọng tâm. Bài luyện tập sẽ điều chỉnh theo lựa chọn này và bạn có thể đổi sau.",
        "Trọng tâm học tập", "Lộ trình trọng tâm của bạn", "Luyện kỹ năng cần được chú ý nhiều nhất",
        "Trọng tâm của tôi", "Đổi trọng tâm", "Bắt đầu luyện tập trọng tâm", "Tốc độ phát",
        "Hủy âm thanh tiếng Đức", "Tạm dừng âm thanh tiếng Đức", "Tiếp tục âm thanh tiếng Đức", "Dừng âm thanh tiếng Đức", "Cải thiện thêm dành cho bạn",
    ],
]

let resourcesURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("DeutschB1Coach/Resources", isDirectory: true)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

for code in catalogFiles.keys.sorted() {
    guard let fileName = catalogFiles[code], let localized = translations[code] else {
        fatalError("Missing catalog mapping for \(code)")
    }
    guard localized.count == sources.count else {
        fatalError("\(code) has \(localized.count) translations; expected \(sources.count)")
    }

    let fileURL = resourcesURL.appendingPathComponent(fileName)
    let data = try Data(contentsOf: fileURL)
    var catalog = try JSONDecoder().decode([String: String].self, from: data)
    for (source, translation) in zip(sources, localized) {
        guard !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Empty \(code) translation for \(source)")
        }
        catalog[source] = translation
    }

    var output = try encoder.encode(catalog)
    output.append(0x0A)
    try output.write(to: fileURL, options: .atomic)
    print("Updated \(code): \(localized.count) strings")
}
