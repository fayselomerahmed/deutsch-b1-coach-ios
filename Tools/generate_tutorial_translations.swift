import Foundation

private let sources = [
    "Skip tutorial",
    "Previous tutorial page",
    "Tutorial progress",
    "Welcome to your German journey",
    "Learn, practice, review, and track progress from one clear home.",
    "Learn with a clear path",
    "Follow A1, A2, and B1 course books in order. Lessons unlock as you make progress.",
    "Build memory with pictures and sound",
    "Every word includes a visual, singular and plural forms, examples, and natural German audio.",
    "Practice real conversations",
    "Listen, speak, and repeat in everyday situations. The coach corrects your answer and helps you try again.",
    "Improve what needs attention",
    "Choose your weakest skill and receive focused practice plus supporting recommendations.",
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
        "መመሪያውን ዝለል", "ወደ ቀዳሚው የመመሪያ ገጽ", "የመመሪያ ሂደት",
        "ወደ ጀርመንኛ የመማር ጉዞዎ እንኳን ደህና መጡ",
        "ከአንድ ግልጽ መነሻ ይማሩ፣ ይለማመዱ፣ ይከልሱ እና እድገትዎን ይከታተሉ።",
        "ግልጽ በሆነ መንገድ ይማሩ",
        "የA1፣ A2 እና B1 የኮርስ መጻሕፍትን በቅደም ተከተል ይከተሉ። እድገት ሲያደርጉ ትምህርቶች ይከፈታሉ።",
        "በምስሎች እና በድምፅ ትውስታዎን ያጠናክሩ",
        "እያንዳንዱ ቃል ምስል፣ ነጠላና ብዙ ቁጥር፣ ምሳሌዎች እና ተፈጥሯዊ የጀርመንኛ ድምፅ አለው።",
        "የእውነተኛ ሕይወት ውይይቶችን ይለማመዱ",
        "በዕለታዊ ሁኔታዎች ያዳምጡ፣ ይናገሩ እና ይድገሙ። አሰልጣኙ መልስዎን ያርማል እና እንደገና እንዲሞክሩ ይረዳዎታል።",
        "ተጨማሪ ትኩረት የሚፈልገውን ያሻሽሉ",
        "በጣም ደካማ ክህሎትዎን ይምረጡ እና የተመረጠ ልምምድ ከደጋፊ ምክሮች ጋር ያግኙ።",
    ],
    "ar": [
        "تخطي البرنامج التعليمي", "صفحة البرنامج التعليمي السابقة", "تقدم البرنامج التعليمي",
        "مرحبًا بك في رحلتك لتعلم الألمانية",
        "تعلّم وتدرّب وراجع وتابع تقدمك من شاشة رئيسية واضحة.",
        "تعلّم عبر مسار واضح",
        "اتبع كتب A1 وA2 وB1 بالترتيب. تُفتح الدروس كلما تقدمت.",
        "ثبّت الكلمات بالصور والصوت",
        "تتضمن كل كلمة صورة وصيغتي المفرد والجمع وأمثلة وصوتًا ألمانيًا طبيعيًا.",
        "تدرّب على محادثات حقيقية",
        "استمع وتحدث وكرر في مواقف يومية. يصحح المدرب إجابتك ويساعدك على المحاولة مرة أخرى.",
        "حسّن ما يحتاج إلى اهتمام",
        "اختر أضعف مهارة لديك واحصل على تدريب مركّز وتوصيات داعمة.",
    ],
    "zh-Hans": [
        "跳过教程", "上一页教程", "教程进度", "欢迎开启德语学习之旅",
        "在一个清晰的主页中学习、练习、复习并跟踪进度。", "沿着清晰路径学习",
        "按顺序学习 A1、A2 和 B1 课程。随着进步，课程会逐步解锁。",
        "用图片和声音强化记忆", "每个单词都有图片、单复数形式、例句和自然的德语音频。",
        "练习真实对话", "在日常情境中听、说并跟读。教练会纠正你的回答并帮助你再次尝试。",
        "强化需要关注的部分", "选择最薄弱的技能，获得重点练习和辅助建议。",
    ],
    "nl": [
        "Tutorial overslaan", "Vorige tutorialpagina", "Tutorialvoortgang", "Welkom bij je reis door het Duits",
        "Leer, oefen, herhaal en volg je voortgang vanuit één duidelijk startscherm.", "Leer via een duidelijk pad",
        "Volg de cursusboeken A1, A2 en B1 op volgorde. Lessen worden ontgrendeld naarmate je vordert.",
        "Onthoud met beelden en geluid", "Elk woord bevat een afbeelding, enkelvoud en meervoud, voorbeelden en natuurlijk Duits geluid.",
        "Oefen echte gesprekken", "Luister, spreek en herhaal in alledaagse situaties. De coach verbetert je antwoord en helpt je het opnieuw te proberen.",
        "Verbeter wat aandacht nodig heeft", "Kies je zwakste vaardigheid en ontvang gerichte oefeningen plus ondersteunende aanbevelingen.",
    ],
    "fr": [
        "Passer le tutoriel", "Page précédente du tutoriel", "Progression du tutoriel", "Bienvenue dans votre parcours d’allemand",
        "Apprenez, entraînez-vous, révisez et suivez vos progrès depuis un accueil clair.", "Apprenez avec un parcours clair",
        "Suivez les cours A1, A2 et B1 dans l’ordre. Les leçons se débloquent au fil de vos progrès.",
        "Mémorisez avec des images et du son", "Chaque mot comprend une image, le singulier et le pluriel, des exemples et un audio allemand naturel.",
        "Entraînez-vous à de vraies conversations", "Écoutez, parlez et répétez dans des situations quotidiennes. Le coach corrige votre réponse et vous aide à réessayer.",
        "Améliorez ce qui demande de l’attention", "Choisissez votre compétence la plus faible et recevez des exercices ciblés ainsi que des recommandations complémentaires.",
    ],
    "hi": [
        "ट्यूटोरियल छोड़ें", "पिछला ट्यूटोरियल पेज", "ट्यूटोरियल की प्रगति", "अपनी जर्मन सीखने की यात्रा में आपका स्वागत है",
        "एक स्पष्ट होम स्क्रीन से सीखें, अभ्यास करें, दोहराएँ और अपनी प्रगति देखें।", "एक स्पष्ट मार्ग से सीखें",
        "A1, A2 और B1 पाठ्यक्रमों को क्रम से पूरा करें। प्रगति के साथ नए पाठ खुलते जाएंगे।",
        "चित्रों और आवाज़ से याददाश्त मजबूत करें", "हर शब्द में चित्र, एकवचन और बहुवचन, उदाहरण और स्वाभाविक जर्मन ऑडियो शामिल हैं।",
        "वास्तविक बातचीत का अभ्यास करें", "रोज़मर्रा की स्थितियों में सुनें, बोलें और दोहराएँ। कोच आपके उत्तर को सुधारता है और फिर से प्रयास करने में मदद करता है।",
        "जिस पर ध्यान चाहिए उसे सुधारें", "अपना सबसे कमजोर कौशल चुनें और केंद्रित अभ्यास के साथ सहायक सुझाव पाएँ।",
    ],
    "id": [
        "Lewati tutorial", "Halaman tutorial sebelumnya", "Kemajuan tutorial", "Selamat datang di perjalanan belajar bahasa Jerman Anda",
        "Belajar, berlatih, mengulang, dan memantau kemajuan dari satu beranda yang jelas.", "Belajar dengan jalur yang jelas",
        "Ikuti buku kursus A1, A2, dan B1 secara berurutan. Pelajaran terbuka seiring kemajuan Anda.",
        "Bangun ingatan dengan gambar dan suara", "Setiap kata dilengkapi gambar, bentuk tunggal dan jamak, contoh, serta audio bahasa Jerman yang alami.",
        "Latih percakapan nyata", "Dengarkan, berbicara, dan ulangi dalam situasi sehari-hari. Pelatih mengoreksi jawaban Anda dan membantu Anda mencoba lagi.",
        "Tingkatkan bagian yang perlu perhatian", "Pilih keterampilan terlemah Anda dan dapatkan latihan terfokus serta rekomendasi pendukung.",
    ],
    "it": [
        "Salta il tutorial", "Pagina precedente del tutorial", "Avanzamento del tutorial", "Benvenuto nel tuo percorso di tedesco",
        "Impara, esercitati, ripassa e controlla i progressi da una schermata iniziale chiara.", "Impara seguendo un percorso chiaro",
        "Segui in ordine i corsi A1, A2 e B1. Le lezioni si sbloccano man mano che progredisci.",
        "Memorizza con immagini e audio", "Ogni parola include un’immagine, il singolare e il plurale, esempi e un audio tedesco naturale.",
        "Esercitati con conversazioni reali", "Ascolta, parla e ripeti in situazioni quotidiane. Il coach corregge la risposta e ti aiuta a riprovare.",
        "Migliora ciò che richiede attenzione", "Scegli l’abilità più debole e ricevi esercizi mirati e consigli di supporto.",
    ],
    "ja": [
        "チュートリアルをスキップ", "チュートリアルの前のページ", "チュートリアルの進行状況", "ドイツ語学習の旅へようこそ",
        "わかりやすいホーム画面から、学習、練習、復習、進捗確認ができます。", "明確な学習ルートで進める",
        "A1、A2、B1 のコースを順番に学びます。進捗に応じてレッスンが開放されます。",
        "画像と音声で記憶に定着", "各単語には画像、単数形と複数形、例文、自然なドイツ語音声があります。",
        "実生活の会話を練習", "日常の場面で聞いて、話して、繰り返します。コーチが回答を修正し、もう一度挑戦できるよう支援します。",
        "必要な部分を重点的に改善", "苦手なスキルを選ぶと、重点練習と補助的なおすすめが表示されます。",
    ],
    "ko": [
        "튜토리얼 건너뛰기", "이전 튜토리얼 페이지", "튜토리얼 진행 상황", "독일어 학습 여정에 오신 것을 환영합니다",
        "명확한 홈 화면에서 학습하고, 연습하고, 복습하며 진도를 확인하세요.", "명확한 학습 경로로 배우기",
        "A1, A2, B1 과정을 순서대로 학습하세요. 진도가 올라가면 다음 수업이 열립니다.",
        "이미지와 소리로 기억하기", "모든 단어에는 이미지, 단수형과 복수형, 예문, 자연스러운 독일어 음성이 포함됩니다.",
        "실제 대화 연습하기", "일상 상황에서 듣고, 말하고, 따라 하세요. 코치가 답변을 교정하고 다시 시도하도록 도와줍니다.",
        "보완이 필요한 부분 향상하기", "가장 약한 능력을 선택하면 집중 연습과 보조 추천을 받을 수 있습니다.",
    ],
    "pl": [
        "Pomiń samouczek", "Poprzednia strona samouczka", "Postęp samouczka", "Witamy na Twojej drodze do języka niemieckiego",
        "Ucz się, ćwicz, powtarzaj i śledź postępy z jednego przejrzystego ekranu głównego.", "Ucz się według jasnej ścieżki",
        "Realizuj kolejno kursy A1, A2 i B1. Lekcje odblokowują się wraz z postępami.",
        "Zapamiętuj dzięki obrazom i dźwiękom", "Każde słowo zawiera obraz, liczbę pojedynczą i mnogą, przykłady oraz naturalne nagranie po niemiecku.",
        "Ćwicz prawdziwe rozmowy", "Słuchaj, mów i powtarzaj w codziennych sytuacjach. Trener poprawia Twoją odpowiedź i pomaga spróbować ponownie.",
        "Poprawiaj to, co wymaga uwagi", "Wybierz najsłabszą umiejętność i otrzymuj ukierunkowane ćwiczenia oraz dodatkowe rekomendacje.",
    ],
    "pt": [
        "Ignorar tutorial", "Página anterior do tutorial", "Progresso do tutorial", "Boas-vindas à sua jornada de alemão",
        "Aprenda, pratique, revise e acompanhe seu progresso em uma tela inicial clara.", "Aprenda com um caminho claro",
        "Siga os cursos A1, A2 e B1 em ordem. As aulas são desbloqueadas conforme você avança.",
        "Memorize com imagens e som", "Cada palavra inclui uma imagem, formas singular e plural, exemplos e áudio natural em alemão.",
        "Pratique conversas reais", "Ouça, fale e repita em situações do dia a dia. O coach corrige sua resposta e ajuda você a tentar novamente.",
        "Melhore o que precisa de atenção", "Escolha sua habilidade mais fraca e receba prática focada e recomendações de apoio.",
    ],
    "ru": [
        "Пропустить обучение", "Предыдущая страница обучения", "Ход обучения", "Добро пожаловать в ваше путешествие по немецкому языку",
        "Учитесь, тренируйтесь, повторяйте и следите за прогрессом на одном понятном главном экране.", "Учитесь по понятному плану",
        "Проходите курсы A1, A2 и B1 по порядку. Уроки открываются по мере вашего прогресса.",
        "Запоминайте с помощью изображений и звука", "Каждое слово содержит изображение, формы единственного и множественного числа, примеры и естественное немецкое аудио.",
        "Практикуйте реальные разговоры", "Слушайте, говорите и повторяйте в повседневных ситуациях. Тренер исправляет ваш ответ и помогает попробовать снова.",
        "Улучшайте то, что требует внимания", "Выберите самый слабый навык и получите целевые упражнения и дополнительные рекомендации.",
    ],
    "es": [
        "Omitir tutorial", "Página anterior del tutorial", "Progreso del tutorial", "Te damos la bienvenida a tu recorrido de alemán",
        "Aprende, practica, repasa y consulta tu progreso desde una pantalla de inicio clara.", "Aprende con una ruta clara",
        "Sigue los cursos A1, A2 y B1 en orden. Las lecciones se desbloquean a medida que avanzas.",
        "Memoriza con imágenes y sonido", "Cada palabra incluye una imagen, las formas singular y plural, ejemplos y audio natural en alemán.",
        "Practica conversaciones reales", "Escucha, habla y repite en situaciones cotidianas. El entrenador corrige tu respuesta y te ayuda a intentarlo de nuevo.",
        "Mejora lo que necesita atención", "Elige tu habilidad más débil y recibe práctica enfocada y recomendaciones complementarias.",
    ],
    "th": [
        "ข้ามบทแนะนำ", "หน้าบทแนะนำก่อนหน้า", "ความคืบหน้าของบทแนะนำ", "ยินดีต้อนรับสู่เส้นทางการเรียนภาษาเยอรมัน",
        "เรียน ฝึก ทบทวน และติดตามความก้าวหน้าจากหน้าหลักที่ชัดเจน", "เรียนตามเส้นทางที่ชัดเจน",
        "เรียนหลักสูตร A1, A2 และ B1 ตามลำดับ บทเรียนจะปลดล็อกเมื่อคุณก้าวหน้า",
        "จดจำด้วยภาพและเสียง", "ทุกคำมีภาพ รูปเอกพจน์และพหูพจน์ ตัวอย่าง และเสียงภาษาเยอรมันที่เป็นธรรมชาติ",
        "ฝึกบทสนทนาในชีวิตจริง", "ฟัง พูด และพูดตามในสถานการณ์ประจำวัน โค้ชจะแก้คำตอบและช่วยให้คุณลองอีกครั้ง",
        "พัฒนาส่วนที่ต้องใส่ใจ", "เลือกทักษะที่อ่อนที่สุดเพื่อรับแบบฝึกที่เน้นเฉพาะด้านและคำแนะนำเสริม",
    ],
    "ti": [
        "መምርሒ ዝለል", "ናብ ዝሓለፈ ገጽ መምርሒ", "ምዕባለ መምርሒ", "ናብ ጉዕዞ ትምህርቲ ጀርመንኛ እንቋዕ ብደሓን መጻእካ",
        "ካብ ሓደ ንጹር መበገሲ ተማሃር፣ ተለማመድ፣ ክለስ እና ምዕባለኻ ተኸታተል።", "ብንጹር መንገዲ ተማሃር",
        "መጻሕፍቲ ኮርስ A1፣ A2ን B1ን ብቕደም ተኸተል። ምዕባለ ክትገብር ከለኻ ትምህርትታት ይኽፈቱ።",
        "ብስእልን ድምጽን ዝኽርኻ ኣደልድል", "ነፍሲ ወከፍ ቃል ስእሊ፣ ነጠላን ብዙሕን፣ ኣብነታትን ተፈጥሯዊ ድምጺ ጀርመንኛን ኣለዎ።",
        "ናይ ሓቂ ዕላላት ተለማመድ", "ኣብ መዓልታዊ ኩነታት ስማዕ፣ ተዛረብን ድገምን። ኣሰልጣኒ መልስኻ የዐሪን እንደገና ክትፍትን ይሕግዘካን።",
        "ትኹረት ዘድልዮ ኣመሓይሽ", "እቲ ዝደኸመ ክእለትካ ምረጽ እሞ ዝተተኮረ ልምምድን ደገፍቲ ምኽርታትን ተቐበል።",
    ],
    "tr": [
        "Eğitimi atla", "Önceki eğitim sayfası", "Eğitim ilerlemesi", "Almanca öğrenme yolculuğunuza hoş geldiniz",
        "Tek bir anlaşılır ana ekrandan öğrenin, alıştırma yapın, tekrar edin ve ilerlemenizi takip edin.", "Net bir yolla öğrenin",
        "A1, A2 ve B1 kurslarını sırayla takip edin. İlerledikçe derslerin kilidi açılır.",
        "Görsel ve sesle kalıcı öğrenin", "Her kelimede görsel, tekil ve çoğul biçimler, örnekler ve doğal Almanca ses bulunur.",
        "Gerçek konuşmaları çalışın", "Günlük durumlarda dinleyin, konuşun ve tekrar edin. Koç yanıtınızı düzeltir ve yeniden denemenize yardımcı olur.",
        "İlgi gerektiren alanı geliştirin", "En zayıf becerinizi seçin; odaklı alıştırmalar ve destekleyici öneriler alın.",
    ],
    "uk": [
        "Пропустити навчання", "Попередня сторінка навчання", "Хід навчання", "Ласкаво просимо до вашої подорожі у вивченні німецької",
        "Навчайтеся, практикуйтеся, повторюйте та стежте за прогресом на одному зрозумілому головному екрані.", "Навчайтеся за чітким маршрутом",
        "Проходьте курси A1, A2 та B1 послідовно. Уроки відкриваються в міру вашого прогресу.",
        "Запам’ятовуйте за допомогою зображень і звуку", "Кожне слово містить зображення, форми однини й множини, приклади та природне німецьке аудіо.",
        "Практикуйте реальні розмови", "Слухайте, говоріть і повторюйте в повсякденних ситуаціях. Тренер виправляє вашу відповідь і допомагає спробувати ще раз.",
        "Покращуйте те, що потребує уваги", "Виберіть найслабшу навичку й отримуйте цільові вправи та додаткові рекомендації.",
    ],
    "vi": [
        "Bỏ qua hướng dẫn", "Trang hướng dẫn trước", "Tiến trình hướng dẫn", "Chào mừng bạn đến với hành trình học tiếng Đức",
        "Học, luyện tập, ôn lại và theo dõi tiến độ từ một màn hình chính rõ ràng.", "Học theo lộ trình rõ ràng",
        "Học lần lượt các khóa A1, A2 và B1. Bài học sẽ mở khóa khi bạn tiến bộ.",
        "Ghi nhớ bằng hình ảnh và âm thanh", "Mỗi từ đều có hình ảnh, dạng số ít và số nhiều, ví dụ và âm thanh tiếng Đức tự nhiên.",
        "Luyện hội thoại thực tế", "Nghe, nói và lặp lại trong các tình huống hằng ngày. Huấn luyện viên sửa câu trả lời và giúp bạn thử lại.",
        "Cải thiện phần cần chú ý", "Chọn kỹ năng yếu nhất để nhận bài luyện tập trọng tâm và đề xuất hỗ trợ.",
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
    catalog.removeValue(forKey: "Learn, practise, review, and track progress from one clear home.")
    for (source, translation) in zip(sources, localized) {
        guard !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Empty \(code) translation for \(source)")
        }
        catalog[source] = translation
    }

    var output = try encoder.encode(catalog)
    output.append(0x0A)
    try output.write(to: fileURL, options: .atomic)
    print("Updated \(code): \(localized.count) tutorial strings")
}
