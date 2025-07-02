//
//  ClassifyDeeplinkTool.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/1/25.
//

import Foundation
import FoundationModels

struct DeepLinkOption: Equatable, Decodable {
    let intent:  ClassifiedDeeplinkIntent.UserIntentIdentifier
    let keywords: [String]
}

@Generable
struct ClassifiedDeeplinkIntent: Equatable {
    @Generable(description: "An enumeration of user intent identifiers.")
    enum UserIntentIdentifier: String, Codable, Equatable, CaseIterable {
        case payment
        case scheduleAppointment
        case checkFICO
        case findATM
        case cardManagement
        case accountQuery
        case unknown
    }

    let intent: UserIntentIdentifier
}

@Observable
final class ClassifyDeeplinkTool: Tool {
    let name = "classifyDeeplink"
    let description = "Classifies user input to a matching intent based on predefined intents and keywords."

    let deeplinkOptions: [DeepLinkOption]

    init() {
        deeplinkOptions = Self.loadDeeplinkMappings()
    }

    @Generable
    struct Arguments {
        @Guide(description: "The user's natural language input, like 'Show me my transactions'")
        let input: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let lowercased = arguments.input.lowercased()

        let words = Set(lowercased.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })
        var bestMatch: (intent: ClassifiedDeeplinkIntent.UserIntentIdentifier, score: Int)? = nil
        for option in deeplinkOptions {
            let optionWords = option.keywords.flatMap { $0.lowercased().split(separator: " ") }.map(String.init)
            let overlap = optionWords.filter { words.contains($0) }.count
            if overlap > 0, (bestMatch == nil || overlap > bestMatch!.score) {
                bestMatch = (option.intent, overlap)
            }
        }
        if let best = bestMatch {
            return ToolOutput("Matched intent: \(best.intent)")
        }
        return ToolOutput("No matching intent found for: '\(arguments.input)'")
    }
}

extension ClassifyDeeplinkTool {
    static func loadDeeplinkMappings() -> [DeepLinkOption] {
        guard let url = Bundle.main.url(forResource: "DeeplinkMappings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([DeepLinkOption].self, from: data) else {
            return []
        }
        return decoded
    }

    var deeplinkMapping: String {
        deeplinkOptions.map {
            "- \($0.intent): \($0.keywords.joined(separator: ", "))"
        }.joined(separator: "\n")
    }
}
