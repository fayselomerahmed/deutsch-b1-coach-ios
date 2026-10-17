import Foundation

/// Keeps immutable course values only until the owner-content revision changes.
/// Main-actor isolation matches ContentLoader and avoids duplicate concurrent work.
@MainActor
final class ContentRevisionCache {
    private var revision: UUID?
    private var values: [String: Any] = [:]

    func value<Value>(
        forKey key: String,
        revision requestedRevision: UUID,
        load: () throws -> Value
    ) rethrows -> Value {
        if revision != requestedRevision {
            values.removeAll(keepingCapacity: true)
            revision = requestedRevision
        }
        if let cached = values[key] as? Value {
            return cached
        }

        // Failed reads are deliberately not cached: a subsequent retry can recover.
        let result = try load()
        // Nested loads are supported; never retain a value from an older revision.
        if revision == requestedRevision {
            values[key] = result
        }
        return result
    }
}
