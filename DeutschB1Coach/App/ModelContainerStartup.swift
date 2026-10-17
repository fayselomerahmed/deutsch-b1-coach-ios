import Combine

/// Keeps startup failure separate from the working app. The only way to recover
/// is to reopen the same persistent container through the supplied builder.
@MainActor
final class ModelContainerStartup<Container>: ObservableObject {
    @Published private(set) var container: Container?
    @Published private(set) var hasFailed = false
    private let makeContainer: () throws -> Container

    init(makeContainer: @escaping () throws -> Container) {
        self.makeContainer = makeContainer
        retry()
    }

    func retry() {
        // Reusing a successful container also keeps every app window connected
        // to the same store instead of opening replacements during view updates.
        guard container == nil else { return }
        do {
            container = try makeContainer()
            hasFailed = false
        } catch {
            container = nil
            hasFailed = true
        }
    }
}
