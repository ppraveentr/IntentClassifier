import Foundation
import IntentClassifier
import FoundationModels

@Observable @MainActor
public final class IntentSampleGenerator {
    private var session: LanguageModelSession

    @MainActor
    static let instructions: Instructions = {
        let values = IntentKeywordMappingProvider.deeplinkCategory.joined(separator: ", ")
        return Instructions {
                """
                You are an banking expert in generating user query that a person can ask a chat bot to execute an action.
                Supproted intent category: \(values).
                Each should be plausible, in natural English and unique reason.
                For payment intent, be creative with name and if needed include purpose, amount (USD) and/or add future date in natural language.
                DO NOT USE similar use case.
                """
        }
    }()

    init() {
        self.session = LanguageModelSession(instructions: Self.instructions)
    }

    func generateSamples() async throws -> [InputModel] {
        var samples: [InputModel] = []
        for intent in IntentKeywordMappingProvider.deeplinkCategory {
            do {
                let prompt = Prompt {
                """
                Write 3 realistic user banking request examples for intent category: \(intent).
                Return as an array of InputModel.
                """
                }
                let result = try await session.respond(to: prompt, generating: [InputModel].self, includeSchemaInPrompt: false, options: GenerationOptions(sampling: .greedy))
                samples.append(contentsOf: result.content)
            } catch {
                continue
            }
        }
        return samples
    }
}
