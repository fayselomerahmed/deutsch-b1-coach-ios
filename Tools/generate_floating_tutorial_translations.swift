import Foundation

private let sources = ["Open feature tutorial", "Close feature tutorial"]
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
    "am": ["የባህሪ መመሪያን ክፈት", "የባህሪ መመሪያን ዝጋ"],
    "ar": ["فتح دليل الميزة", "إغلاق دليل الميزة"],
    "zh-Hans": ["打开功能指南", "关闭功能指南"],
    "nl": ["Functiegids openen", "Functiegids sluiten"],
    "fr": ["Ouvrir le guide de la fonctionnalité", "Fermer le guide de la fonctionnalité"],
    "hi": ["फ़ीचर गाइड खोलें", "फ़ीचर गाइड बंद करें"],
    "id": ["Buka panduan fitur", "Tutup panduan fitur"],
    "it": ["Apri la guida della funzione", "Chiudi la guida della funzione"],
    "ja": ["機能ガイドを開く", "機能ガイドを閉じる"],
    "ko": ["기능 안내 열기", "기능 안내 닫기"],
    "pl": ["Otwórz przewodnik po funkcji", "Zamknij przewodnik po funkcji"],
    "pt": ["Abrir guia do recurso", "Fechar guia do recurso"],
    "ru": ["Открыть руководство по разделу", "Закрыть руководство по разделу"],
    "es": ["Abrir guía de la función", "Cerrar guía de la función"],
    "th": ["เปิดคำแนะนำฟีเจอร์", "ปิดคำแนะนำฟีเจอร์"],
    "ti": ["መምርሒ ባህሪ ክፈት", "መምርሒ ባህሪ ዕጾ"],
    "tr": ["Özellik rehberini aç", "Özellik rehberini kapat"],
    "uk": ["Відкрити довідку про функцію", "Закрити довідку про функцію"],
    "vi": ["Mở hướng dẫn tính năng", "Đóng hướng dẫn tính năng"],
]

let resourcesURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("DeutschB1Coach/Resources", isDirectory: true)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

for code in catalogFiles.keys.sorted() {
    guard let fileName = catalogFiles[code], let localized = translations[code],
          localized.count == sources.count else {
        fatalError("Missing floating tutorial translations for \(code)")
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
    print("Updated \(code): floating tutorial accessibility")
}
