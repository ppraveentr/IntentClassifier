//
//  IntentClassifier.swift
//  BankingIntentClasifier
//
//  Created by Praveen Prabhakar on 6/30/25.
//

import Foundation
import FoundationModels

@Observable @MainActor
public final class IntentClassifier {
    private var session: LanguageModelSession

    static func instructions(_ deeplinkMapping: String, examples: String) -> Instructions {
        Instructions {
            """
            You are an expert banking assistant.
            Your role is to classify the query into one of the supported intents listed below.
            The user input can be creative in natural language.
            
            Supported intents:
            \(deeplinkMapping)

            The intent may be expressed using synonyms, paraphrases, or related phrases; always pick the *closest matching* intent, even if the words are not an exact match to the keywords.
            Do not create new intents, and do not ask for clarification.

            For each user input:
            - respond with intent identifier that only matches the best.

            Example inputs and expected outputs:
            \(examples)

            Output: 
            - intent = "<intent identifier>"
            """
        }
    }

    public init() {
        let deeplinkMapping = IntentKeywordMappingProvider.intentKeywordsMapping
        let deeplinkExampls = IntentKeywordMappingProvider.categoryExamples
        let paymenttool = CapturePaymentIntentTool()

        self.session = LanguageModelSession(
            tools: [paymenttool],
            instructions: Self.instructions(deeplinkMapping, examples: deeplinkExampls)
        )
    }

    @MainActor
    public func captureIntent(_ text: String) async throws -> [String: Any?] {
        let promt = Prompt({
            """
            Extract the user's intent and details for this request:
            \(text)
            """
        })
        do {
            let classified = try await session.respond(to: promt, generating: DeeplinkIntent.self, includeSchemaInPrompt: false, options: GenerationOptions(sampling: .greedy))
            print(classified.content.intent)
            print(String(describing: classified.content.paymentDetails?.formatedOutput))
            let intent = classified.content.intent
            let data = classified.content.paymentDetails?.formatedOutput
            return [intent: data]
        } catch {
            print("❌ Error: \(error)")
            throw error
        }
    }

    public func prewarmSession() {
        session.prewarm()
    }
}

