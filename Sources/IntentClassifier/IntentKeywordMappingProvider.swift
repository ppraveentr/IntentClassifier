import Foundation

/// A public model for intent-keyword mapping.
public struct IntentKeywordMapping: Codable, Equatable, Sendable {
    public let intent: String
    public let keywords: [String]
    public let examples: [String]
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

    /// Returns the List of Intent-Keyword mapping
    public static var intentKeywordsMapping: String {
        let mapping = IntentKeywordMappingProvider.shared.mapping
        return mapping.map {
            "- \($0.intent): \($0.keywords.joined(separator: ", "))"
        }.joined(separator: "\n")
    }

    /// Returns the List of Intents
    public static var deeplinkCategory: [String] {
        let mapping = IntentKeywordMappingProvider.shared.mapping
        return mapping.map { $0.intent }
    }

    /// Returns the List of exampls for all intents
    public static var categoryExamples: String {
        let mapping = IntentKeywordMappingProvider.shared.mapping
        return mapping.flatMap { obj in
            obj.examples.flatMap { ex in
                ["- Input: '\(ex)' -> Output: intent = '\(obj.intent)'"]
            }.joined(separator: "\n")
        }.joined(separator: "\n")
    }
}
