import Foundation

/// A public model for intent-keyword mapping.
public struct IntentKeywordMapping: Codable, Equatable, Sendable {
    public let intent: String
    public let keywords: [String]
}

/// Provides access to intent-keyword mapping from a JSON payload.
public final class IntentKeywordMappingProvider {
    public var mapping: [IntentKeywordMapping] = []
    var mappingJsonUrl: URL?

    public nonisolated(unsafe) static let shared = IntentKeywordMappingProvider()

    public func loadMappingJson(from url: URL?) throws {
        guard let url else { return }
        let data = try Data(contentsOf: url)
        try Self.loadIntendKeywordMappings(data: data)
    }

    /// Returns the array of intent-keyword mappings.
    public static func loadIntendKeywordMappings(data: Data) throws -> [IntentKeywordMapping] {
        let mapping = try JSONDecoder().decode([IntentKeywordMapping].self, from: data)
        IntentKeywordMappingProvider.shared.mapping = mapping
        return mapping
    }

    public static var intentKeywordsMapping: String {
        let mapping = IntentKeywordMappingProvider.shared.mapping
        return mapping.map {
            "- \($0.intent): \($0.keywords.joined(separator: ", "))"
        }.joined(separator: "\n")
    }

    /// MainActor-isolated. Use only where MainActor context is guaranteed.
    public static var deeplinkCategory: [String] {
        let mapping = IntentKeywordMappingProvider.shared.mapping
        return mapping.map { $0.intent }
    }
}
