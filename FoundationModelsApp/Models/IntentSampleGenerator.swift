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
                For payment intent, be creative with name, purpose, amount (USD) and add future date in natural language.
                Each should be plausible, in natural English and unique reason.
                DO NOT USE similar use case, be creative, try to include dates and amount.
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
