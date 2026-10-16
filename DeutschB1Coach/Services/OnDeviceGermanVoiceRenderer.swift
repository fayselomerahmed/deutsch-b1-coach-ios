import Foundation

final class OnDeviceGermanVoiceRenderer: @unchecked Sendable {
    static let shared = OnDeviceGermanVoiceRenderer()

    private struct VoiceResources {
        let model: URL
        let tokens: URL
        let dataDirectory: URL
    }

    private let queue = DispatchQueue(
        label: "com.faysel.DeutschB1Coach.neural-voice",
        qos: .userInitiated
    )
    private let fileManager = FileManager.default
    private var engine: DBCNeuralTTSBridge?
    private var didAttemptEngineCreation = false

    private init() {}

    var hasBundledModel: Bool {
        Self.voiceResources() != nil
    }

    func render(_ text: String, completion: @escaping (URL?) -> Void) {
        let resourceName = GermanSpeechService.neuralResourceName(for: text)

        queue.async { [weak self] in
            guard let self else { return }
            let result = autoreleasepool {
                self.renderOnQueue(text, resourceName: resourceName)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func renderOnQueue(_ text: String, resourceName: String) -> URL? {
        guard let cacheDirectory = cacheDirectory() else { return nil }
        let outputURL = cacheDirectory.appendingPathComponent(
            "dynamic_\(resourceName).wav",
            isDirectory: false
        )

        if isValidAudioFile(outputURL) {
            return outputURL
        }

        guard let engine = speechEngine() else { return nil }
        let temporaryURL = cacheDirectory.appendingPathComponent(
            ".\(UUID().uuidString).wav",
            isDirectory: false
        )
        defer { try? fileManager.removeItem(at: temporaryURL) }

        guard engine.writeSpeech(text: text, outputPath: temporaryURL.path, speed: 1),
              isValidAudioFile(temporaryURL)
        else {
            return nil
        }

        try? fileManager.removeItem(at: outputURL)
        do {
            try fileManager.moveItem(at: temporaryURL, to: outputURL)
            pruneCache(in: cacheDirectory, preserving: outputURL)
            return outputURL
        } catch {
            return nil
        }
    }

    private func speechEngine() -> DBCNeuralTTSBridge? {
        if let engine {
            return engine
        }
        guard !didAttemptEngineCreation, let resources = Self.voiceResources() else {
            return nil
        }

        didAttemptEngineCreation = true
        let createdEngine = DBCNeuralTTSBridge(
            modelPath: resources.model.path,
            tokensPath: resources.tokens.path,
            dataDirectory: resources.dataDirectory.path
        )
        engine = createdEngine
        return createdEngine
    }

    private func cacheDirectory() -> URL? {
        guard let root = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = root.appendingPathComponent("GermanNeuralVoice", isDirectory: true)
        do {
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            return directory
        } catch {
            return nil
        }
    }

    private func isValidAudioFile(_ url: URL) -> Bool {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey]) else {
            return false
        }
        return (values.fileSize ?? 0) > 44
    }

    private func pruneCache(in directory: URL, preserving currentURL: URL) {
        let keys: Set<URLResourceKey> = [.contentModificationDateKey, .fileSizeKey]
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        let cachedFiles = urls.filter { $0.pathExtension == "wav" }
        guard cachedFiles.count > 60 else { return }

        let oldestFirst = cachedFiles.sorted {
            let left = try? $0.resourceValues(forKeys: keys).contentModificationDate
            let right = try? $1.resourceValues(forKeys: keys).contentModificationDate
            return (left ?? .distantPast) < (right ?? .distantPast)
        }
        for url in oldestFirst.prefix(cachedFiles.count - 60) where url != currentURL {
            try? fileManager.removeItem(at: url)
        }
    }

    private static func voiceResources(bundle: Bundle = .main) -> VoiceResources? {
        let subdirectory = "NeuralTTSModel"
        guard let model = bundle.url(
            forResource: "de_DE-thorsten-high",
            withExtension: "onnx",
            subdirectory: subdirectory
        ),
        let tokens = bundle.url(
            forResource: "tokens",
            withExtension: "txt",
            subdirectory: subdirectory
        ),
        let dataDirectory = bundle.url(
            forResource: "espeak-ng-data",
            withExtension: nil,
            subdirectory: subdirectory
        ) else {
            return nil
        }

        return VoiceResources(
            model: model,
            tokens: tokens,
            dataDirectory: dataDirectory
        )
    }
}
