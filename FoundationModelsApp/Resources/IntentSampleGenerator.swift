import Foundation
import IntentClassifier
import FoundationModels

@Observable @MainActor
public final class IntentSampleGenerator {
    private var session: LanguageModelSession

    @MainActor
    static let instructions: Instructions = {
        let values = UserIntent.allKeys.joined(separator: ", ")
        return Instructions {
                """
                You are an expert in generating user query that a person can ask a chat bot to execute an action.
                Supproted intent category: \(values).
                For payment intent, randomly include amount in USD and add future date.
                Each should be plausible and in natural English.
                Do NOT number the items. Separate each with a newline.
                """
        }
    }()

    init() {
        self.session = LanguageModelSession(instructions: Self.instructions)
    }

    func generateSamples() async throws -> [InputModel] {
        var samples: [InputModel] = []
        for intent in UserIntent.allKeys {
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
