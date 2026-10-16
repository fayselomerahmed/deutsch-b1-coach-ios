import Foundation

private let sources = [
    "Your daily learning home",
    "Continue your next lesson, see today's practice, and reach the most useful action without searching.",
    "Understand grammar visually",
    "See word order, cases, articles, and sentence structure before practicing them.",
    "Review and play",
    "Use flashcards, matching games, and sentence challenges to bring difficult material back at the right time.",
    "See your progress",
    "Follow your course journey, streak, mastered words, and B1 readiness as you improve.",
    "Prepare for the B1 exam",
    "Practice reading, listening, writing, and speaking with guided tasks and realistic mock exams.",
    "Prepare for life in Germany",
    "Study the official 300 questions plus 10 questions for your federal state, then take randomized mock tests.",
]

private let catalogFiles = [
    "am": "amharic_translations.json", "ar": "ar_translations.json",
    "zh-Hans": "zh-Hans_translations.json", "nl": "nl_translations.json",
    "fr": "fr_translations.json", "hi": "hi_translations.json",
    "id": "id_translations.json", "it": "it_translations.json",
    "ja": "ja_translations.json", "ko": "ko_translations.json",
    "pl": "pl_translations.json", "pt": "pt_translations.json",
    "ru": "ru_translations.json", "es": "es_translations.json",
    "th": "th_translations.json", "ti": "ti_translations.json",
    "tr": "tr_translations.json", "uk": "uk_translations.json",
    "vi": "vi_translations.json",
]

private let translations: [String: [String]] = [
    "am": [
        "የዕለት ተዕለት የመማሪያ መነሻዎ",
        "ቀጣዩን ትምህርት ይቀጥሉ፣ የዛሬውን ልምምድ ይመልከቱ እና ሳይፈልጉ በጣም ጠቃሚውን ተግባር ያግኙ።",
        "ሰዋሰውን በምስል ይረዱ",
        "ከመለማመድዎ በፊት የቃላት ቅደም ተከተል፣ ኬዞች፣ አርቲክሎች እና የዓረፍተ ነገር አወቃቀርን ይመልከቱ።",
        "ይከልሱ እና ይጫወቱ",
        "አስቸጋሪ ትምህርቶችን በትክክለኛው ጊዜ ለመመለስ ፍላሽ ካርዶችን፣ ማዛመጃ ጨዋታዎችን እና የዓረፍተ ነገር ፈተናዎችን ይጠቀሙ።",
        "እድገትዎን ይመልከቱ",
        "እየተሻሻሉ ሲሄዱ የኮርስ ጉዞዎን፣ ተከታታይ ቀናትዎን፣ የተማሩ ቃላትን እና የB1 ዝግጁነትን ይከታተሉ።",
        "ለB1 ፈተና ይዘጋጁ",
        "ንባብን፣ ማዳመጥን፣ ጽሑፍን እና ንግግርን በተመሩ ተግባራት እና ተጨባጭ የሙከራ ፈተናዎች ይለማመዱ።",
        "በጀርመን ለመኖር ይዘጋጁ",
        "300ዎቹን ይፋዊ ጥያቄዎች እና ለእርስዎ ፌዴራል ግዛት 10 ጥያቄዎችን ይማሩ፣ ከዚያም የዘፈቀደ የሙከራ ፈተናዎችን ይውሰዱ።",
    ],
    "ar": [
        "صفحتك الرئيسية للتعلم اليومي",
        "تابع درسك التالي، واطّلع على تدريب اليوم، وانتقل إلى الإجراء الأكثر فائدة من دون بحث.",
        "افهم القواعد بصريًا", "شاهد ترتيب الكلمات والحالات وأدوات التعريف وبنية الجملة قبل التدرب عليها.",
        "راجع والعب", "استخدم البطاقات التعليمية وألعاب المطابقة وتحديات الجمل لإعادة المواد الصعبة في الوقت المناسب.",
        "شاهد تقدمك", "تابع مسار الدورة وسلسلة أيامك والكلمات التي أتقنتها واستعدادك لـ B1 أثناء تقدمك.",
        "استعد لامتحان B1", "تدرّب على القراءة والاستماع والكتابة والتحدث من خلال مهام موجهة وامتحانات تجريبية واقعية.",
        "استعد للحياة في ألمانيا", "ادرس الأسئلة الرسمية الـ300 إضافة إلى 10 أسئلة لولايتك، ثم خض اختبارات تجريبية عشوائية.",
    ],
    "zh-Hans": [
        "你的每日学习主页", "继续下一课、查看今日练习，无需寻找即可进入最有用的任务。",
        "直观理解语法", "先看懂语序、格、冠词和句子结构，再开始练习。",
        "复习并游戏", "使用闪卡、配对游戏和句子挑战，在合适的时间重新练习难点。",
        "查看你的进度", "随着提升，跟踪课程旅程、连续学习天数、已掌握单词和 B1 准备度。",
        "准备 B1 考试", "通过指导任务和真实模拟考试练习阅读、听力、写作和口语。",
        "为在德国生活做好准备", "学习官方 300 道题及所在联邦州的 10 道题，然后参加随机模拟考试。",
    ],
    "nl": [
        "Jouw start voor dagelijks leren", "Ga verder met je volgende les, bekijk de oefening van vandaag en bereik direct de nuttigste actie.",
        "Begrijp grammatica visueel", "Bekijk woordvolgorde, naamvallen, lidwoorden en zinsbouw voordat je ermee oefent.",
        "Herhaal en speel", "Gebruik flashcards, koppelspellen en zinsuitdagingen om moeilijke stof op het juiste moment terug te brengen.",
        "Bekijk je voortgang", "Volg je cursusroute, reeks, beheerste woorden en B1-gereedheid terwijl je vooruitgaat.",
        "Bereid je voor op het B1-examen", "Oefen lezen, luisteren, schrijven en spreken met begeleide opdrachten en realistische proefexamens.",
        "Bereid je voor op het leven in Duitsland", "Bestudeer de 300 officiële vragen plus 10 vragen voor jouw deelstaat en maak daarna willekeurige proefexamens.",
    ],
    "fr": [
        "Votre accueil d’apprentissage quotidien", "Reprenez votre prochaine leçon, consultez l’exercice du jour et accédez directement à l’action la plus utile.",
        "Comprenez la grammaire visuellement", "Visualisez l’ordre des mots, les cas, les articles et la structure des phrases avant de vous exercer.",
        "Révisez et jouez", "Utilisez des cartes mémoire, des jeux d’association et des défis de phrases pour revoir les difficultés au bon moment.",
        "Suivez vos progrès", "Suivez votre parcours, votre série, les mots maîtrisés et votre préparation au B1 à mesure que vous progressez.",
        "Préparez l’examen B1", "Entraînez la lecture, l’écoute, l’écriture et l’oral avec des tâches guidées et des examens blancs réalistes.",
        "Préparez-vous à la vie en Allemagne", "Étudiez les 300 questions officielles et les 10 questions de votre Land, puis passez des examens blancs aléatoires.",
    ],
    "hi": [
        "आपका रोज़ का सीखने का होम", "अपना अगला पाठ जारी रखें, आज का अभ्यास देखें और बिना खोजे सबसे उपयोगी गतिविधि तक पहुँचें।",
        "व्याकरण को चित्रों से समझें", "अभ्यास से पहले शब्द क्रम, कारक, आर्टिकल और वाक्य संरचना देखें।",
        "दोहराएँ और खेलें", "कठिन सामग्री को सही समय पर वापस लाने के लिए फ्लैशकार्ड, मिलान खेल और वाक्य चुनौतियों का उपयोग करें।",
        "अपनी प्रगति देखें", "आगे बढ़ते हुए अपना पाठ्यक्रम, लगातार सीखने के दिन, सीखे हुए शब्द और B1 की तैयारी देखें।",
        "B1 परीक्षा की तैयारी करें", "निर्देशित गतिविधियों और वास्तविक मॉक परीक्षाओं से पढ़ना, सुनना, लिखना और बोलना अभ्यास करें।",
        "जर्मनी में जीवन की तैयारी करें", "आधिकारिक 300 प्रश्नों और अपने संघीय राज्य के 10 प्रश्नों का अध्ययन करें, फिर यादृच्छिक मॉक टेस्ट दें।",
    ],
    "id": [
        "Beranda belajar harian Anda", "Lanjutkan pelajaran berikutnya, lihat latihan hari ini, dan buka tindakan paling berguna tanpa mencari.",
        "Pahami tata bahasa secara visual", "Lihat urutan kata, kasus, artikel, dan struktur kalimat sebelum berlatih.",
        "Ulangi dan bermain", "Gunakan kartu kilat, permainan mencocokkan, dan tantangan kalimat untuk mengulang materi sulit pada waktu yang tepat.",
        "Lihat kemajuan Anda", "Ikuti perjalanan kursus, rentetan belajar, kata yang dikuasai, dan kesiapan B1 saat Anda berkembang.",
        "Bersiap untuk ujian B1", "Latih membaca, menyimak, menulis, dan berbicara dengan tugas terpandu dan ujian simulasi yang realistis.",
        "Bersiap untuk hidup di Jerman", "Pelajari 300 pertanyaan resmi ditambah 10 pertanyaan untuk negara bagian Anda, lalu ikuti ujian simulasi acak.",
    ],
    "it": [
        "La tua home di apprendimento quotidiano", "Continua la prossima lezione, guarda l’esercizio di oggi e raggiungi subito l’attività più utile.",
        "Comprendi visivamente la grammatica", "Osserva l’ordine delle parole, i casi, gli articoli e la struttura della frase prima di esercitarti.",
        "Ripassa e gioca", "Usa flashcard, giochi di abbinamento e sfide con le frasi per riprendere gli argomenti difficili al momento giusto.",
        "Guarda i tuoi progressi", "Segui il percorso, la serie, le parole apprese e la preparazione al B1 mentre migliori.",
        "Preparati per l’esame B1", "Esercita lettura, ascolto, scrittura e parlato con attività guidate ed esami simulati realistici.",
        "Preparati alla vita in Germania", "Studia le 300 domande ufficiali più le 10 del tuo Land, poi svolgi simulazioni casuali dell’esame.",
    ],
    "ja": [
        "毎日の学習ホーム", "次のレッスンを続け、今日の練習を確認し、探すことなく最も役立つ活動へ進めます。",
        "文法を視覚的に理解", "練習する前に、語順、格、冠詞、文の構造を視覚的に確認します。",
        "復習して遊ぶ", "フラッシュカード、マッチングゲーム、文の課題で、難しい内容を適切なタイミングで復習します。",
        "進捗を確認", "上達に合わせて、コースの道のり、連続学習、習得した単語、B1 の準備度を確認します。",
        "B1 試験に備える", "ガイド付き課題と実践的な模擬試験で、読む・聞く・書く・話すを練習します。",
        "ドイツでの生活に備える", "公式の300問と居住する州の10問を学び、ランダムな模擬試験に挑戦します。",
    ],
    "ko": [
        "매일 학습하는 홈", "다음 수업을 이어서 하고, 오늘의 연습을 확인하며, 찾을 필요 없이 가장 유용한 활동으로 이동하세요.",
        "문법을 시각적으로 이해하기", "연습하기 전에 어순, 격, 관사와 문장 구조를 눈으로 확인하세요.",
        "복습하며 게임하기", "플래시카드, 짝 맞추기 게임과 문장 도전으로 어려운 내용을 알맞은 때에 다시 학습하세요.",
        "진도 확인하기", "학습하면서 과정 여정, 연속 학습, 익힌 단어와 B1 준비도를 확인하세요.",
        "B1 시험 준비하기", "안내 과제와 실전형 모의시험으로 읽기, 듣기, 쓰기와 말하기를 연습하세요.",
        "독일 생활 준비하기", "공식 300문항과 거주 연방주의 10문항을 학습한 뒤 무작위 모의시험을 치르세요.",
    ],
    "pl": [
        "Twój ekran codziennej nauki", "Kontynuuj następną lekcję, zobacz dzisiejsze ćwiczenie i od razu przejdź do najważniejszego działania.",
        "Zrozum gramatykę wizualnie", "Zobacz szyk wyrazów, przypadki, rodzajniki i budowę zdania, zanim zaczniesz ćwiczyć.",
        "Powtarzaj i graj", "Używaj fiszek, gier w dopasowywanie i wyzwań zdaniowych, aby wracać do trudnego materiału we właściwym czasie.",
        "Zobacz swoje postępy", "Śledź drogę kursu, serię, opanowane słowa i gotowość do B1 wraz z rozwojem umiejętności.",
        "Przygotuj się do egzaminu B1", "Ćwicz czytanie, słuchanie, pisanie i mówienie za pomocą zadań z instrukcjami i realistycznych egzaminów próbnych.",
        "Przygotuj się do życia w Niemczech", "Ucz się 300 oficjalnych pytań oraz 10 pytań dla swojego kraju związkowego, a potem rozwiązuj losowe testy próbne.",
    ],
    "pt": [
        "Sua tela inicial de aprendizagem diária", "Continue sua próxima aula, veja a prática de hoje e acesse a ação mais útil sem precisar procurar.",
        "Entenda a gramática visualmente", "Veja a ordem das palavras, os casos, os artigos e a estrutura da frase antes de praticar.",
        "Revise e jogue", "Use cartões, jogos de associação e desafios de frases para rever conteúdos difíceis no momento certo.",
        "Veja seu progresso", "Acompanhe o percurso, a sequência, as palavras dominadas e a preparação para o B1 conforme você melhora.",
        "Prepare-se para o exame B1", "Pratique leitura, compreensão oral, escrita e fala com tarefas guiadas e simulados realistas.",
        "Prepare-se para viver na Alemanha", "Estude as 300 perguntas oficiais e as 10 perguntas do seu estado federal e faça simulados aleatórios.",
    ],
    "ru": [
        "Ваш главный экран ежедневного обучения", "Продолжайте следующий урок, просматривайте сегодняшнюю практику и сразу переходите к самому полезному действию.",
        "Понимайте грамматику визуально", "Сначала изучите порядок слов, падежи, артикли и структуру предложения, а затем тренируйтесь.",
        "Повторяйте и играйте", "Используйте карточки, игры на сопоставление и задания с предложениями, чтобы вовремя возвращаться к сложному материалу.",
        "Следите за своим прогрессом", "Отслеживайте путь курса, серию занятий, выученные слова и готовность к B1 по мере улучшения.",
        "Подготовьтесь к экзамену B1", "Тренируйте чтение, аудирование, письмо и говорение с заданиями и реалистичными пробными экзаменами.",
        "Подготовьтесь к жизни в Германии", "Изучите 300 официальных вопросов и 10 вопросов для вашей федеральной земли, затем проходите случайные пробные тесты.",
    ],
    "es": [
        "Tu inicio de aprendizaje diario", "Continúa la siguiente lección, consulta la práctica de hoy y accede directamente a la acción más útil.",
        "Comprende la gramática visualmente", "Observa el orden de las palabras, los casos, los artículos y la estructura de la oración antes de practicar.",
        "Repasa y juega", "Usa tarjetas, juegos de asociación y retos de frases para recuperar el contenido difícil en el momento adecuado.",
        "Consulta tu progreso", "Sigue tu recorrido, tu racha, las palabras dominadas y tu preparación para B1 mientras mejoras.",
        "Prepárate para el examen B1", "Practica lectura, comprensión auditiva, escritura y expresión oral con tareas guiadas y simulacros realistas.",
        "Prepárate para vivir en Alemania", "Estudia las 300 preguntas oficiales y las 10 de tu estado federado, y después realiza simulacros aleatorios.",
    ],
    "th": [
        "หน้าหลักสำหรับการเรียนทุกวัน", "เรียนบทถัดไปต่อ ดูแบบฝึกของวันนี้ และไปยังสิ่งที่มีประโยชน์ที่สุดได้ทันทีโดยไม่ต้องค้นหา",
        "เข้าใจไวยากรณ์ด้วยภาพ", "ดูการเรียงคำ การก กำกับนาม และโครงสร้างประโยคก่อนเริ่มฝึก",
        "ทบทวนและเล่น", "ใช้แฟลชการ์ด เกมจับคู่ และโจทย์ประโยคเพื่อนำเนื้อหาที่ยากกลับมาฝึกในเวลาที่เหมาะสม",
        "ดูความก้าวหน้าของคุณ", "ติดตามเส้นทางหลักสูตร จำนวนวันที่เรียนต่อเนื่อง คำที่จำได้ และความพร้อมระดับ B1 ขณะที่คุณพัฒนา",
        "เตรียมสอบ B1", "ฝึกอ่าน ฟัง เขียน และพูดด้วยงานที่มีคำแนะนำและข้อสอบจำลองที่สมจริง",
        "เตรียมพร้อมสำหรับชีวิตในเยอรมนี", "เรียนคำถามทางการ 300 ข้อและอีก 10 ข้อสำหรับรัฐของคุณ แล้วทำข้อสอบจำลองแบบสุ่ม",
    ],
    "ti": [
        "መዓልታዊ መበገሲ ትምህርትኻ", "ዝቕጽል ትምህርትኻ ቀጽል፣ ናይ ሎሚ ልምምድ ርአ እና ከይደለኻ ናብ ዝጠቕም ተግባር ብቐጥታ ብጻሕ።",
        "ሰዋስው ብስእሊ ተረዳእ", "ቅድሚ ልምምድ ቅደም ተኸተል ቃላት፣ ኬዛት፣ ኣርቲክላትን ኣቃውማ ሓረግን ርአ።",
        "ክለስን ተጻወትን", "ከቢድ ትምህርቲ ኣብ ግቡእ ግዜ ንምድጋም ፍላሽ ካርድታት፣ ናይ ምዝማድ ጸወታታትን ናይ ሓረግ ፈተናታትን ተጠቐም።",
        "ምዕባለኻ ርአ", "እናተማሓየሽካ ጉዕዞ ኮርስኻ፣ ተኸታታሊ መዓልትታት፣ ዝተማሃርካዮም ቃላትን ድሉውነት B1ን ተኸታተል።",
        "ንፈተና B1 ተዳሎ", "ምንባብ፣ ምስማዕ፣ ምጽሓፍን ምዝራብን ብዝተመርሑ ተግባራትን ናይ ሓቂ ዝመስሉ ፈተናታትን ተለማመድ።",
        "ንህይወት ኣብ ጀርመን ተዳሎ", "300 ወግዓዊ ሕቶታትን 10 ሕቶታት ናይ ፌደራል ግዝኣትካን ተማሃር፣ ድሕሪኡ ዘይተወሰኑ ፈተናታት ውሰድ።",
    ],
    "tr": [
        "Günlük öğrenme ana sayfanız", "Sıradaki derse devam edin, bugünün alıştırmasını görün ve aramadan en yararlı eyleme ulaşın.",
        "Dil bilgisini görsel olarak anlayın", "Alıştırmadan önce sözcük dizilimini, hâlleri, artikelleri ve cümle yapısını görün.",
        "Tekrar edin ve oynayın", "Zor konuları doğru zamanda yeniden çalışmak için bilgi kartları, eşleştirme oyunları ve cümle görevleri kullanın.",
        "İlerlemenizi görün", "Geliştikçe kurs yolculuğunuzu, serinizi, öğrendiğiniz kelimeleri ve B1 hazırlığınızı takip edin.",
        "B1 sınavına hazırlanın", "Yönlendirmeli görevler ve gerçekçi deneme sınavlarıyla okuma, dinleme, yazma ve konuşma çalışın.",
        "Almanya’daki hayata hazırlanın", "300 resmî soruyu ve eyaletinize ait 10 soruyu çalışın, ardından rastgele deneme sınavlarına girin.",
    ],
    "uk": [
        "Ваш головний екран щоденного навчання", "Продовжуйте наступний урок, переглядайте сьогоднішню практику й одразу переходьте до найкориснішої дії.",
        "Розумійте граматику візуально", "Спочатку перегляньте порядок слів, відмінки, артиклі та структуру речення, а потім практикуйтеся.",
        "Повторюйте та грайте", "Використовуйте картки, ігри на відповідність і завдання з реченнями, щоб вчасно повертатися до складного матеріалу.",
        "Переглядайте свій прогрес", "Стежте за шляхом курсу, серією занять, опанованими словами та готовністю до B1 у міру розвитку.",
        "Підготуйтеся до іспиту B1", "Практикуйте читання, аудіювання, письмо й говоріння за допомогою керованих завдань і реалістичних пробних іспитів.",
        "Підготуйтеся до життя в Німеччині", "Вивчіть 300 офіційних запитань і 10 запитань для своєї федеральної землі, а потім проходьте випадкові пробні тести.",
    ],
    "vi": [
        "Trang chủ học tập hằng ngày", "Tiếp tục bài học kế tiếp, xem bài luyện hôm nay và mở ngay hoạt động hữu ích nhất mà không cần tìm kiếm.",
        "Hiểu ngữ pháp bằng hình ảnh", "Xem trật tự từ, cách, mạo từ và cấu trúc câu trước khi luyện tập.",
        "Ôn tập và chơi", "Dùng thẻ ghi nhớ, trò chơi ghép cặp và thử thách câu để ôn lại nội dung khó vào đúng thời điểm.",
        "Xem tiến độ của bạn", "Theo dõi hành trình khóa học, chuỗi ngày học, từ đã thuộc và mức sẵn sàng B1 khi bạn tiến bộ.",
        "Chuẩn bị cho kỳ thi B1", "Luyện đọc, nghe, viết và nói với bài tập có hướng dẫn và kỳ thi thử sát thực tế.",
        "Chuẩn bị cho cuộc sống ở Đức", "Học 300 câu hỏi chính thức cùng 10 câu hỏi của bang nơi bạn sống, rồi làm các bài thi thử ngẫu nhiên.",
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
        catalog[source] = translation
    }

    var output = try encoder.encode(catalog)
    output.append(0x0A)
    try output.write(to: fileURL, options: .atomic)
    print("Updated \(code): \(localized.count) feature strings")
}
