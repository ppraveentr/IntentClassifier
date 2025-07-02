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

    static func instructions(_ deeplinkMapping: String) -> Instructions {
        Instructions {
            """
            You are an expert banking assistant.
            Your role is to classify the query into one of the supported intents listed below.

            Supported intents:
            \(deeplinkMapping)

            The intent may be expressed using synonyms, paraphrases, or related phrases; always pick the *closest matching* intent, even if the words are not an exact match to the keywords.
            Do not create new intents, and do not ask for clarification.

            For each user input:
            - respond with intent identifier that only matches the best.

            Example inputs and expected outputs:
            - Input: "Send $50 to Mom tomorrow from checking account" \u{2192} Output: intent = "payment"
            - Input: "Pay my Chase credit card bill on July 10" \u{2192} Output: intent = "payment"
            - Input: "What's my current FICO score?" \u{2192} Output: intent = "checkFICO"
            - Input: "Show me my credit score" \u{2192} Output: intent = "checkFICO"
            - Input: "Find the nearest ATM" \u{2192} Output: intent = "findATM"
            - Input: "Freeze my debit card" \u{2192} Output: intent = "cardManagement"
            - Input: "What's my checking balance?" \u{2192} Output: intent = "accountQuery"
            - Input: "Schedule an appointment with a banker next Friday" \u{2192} Output: intent = "scheduleAppointment"
            - Input: "Show me recent transactions in savings" \u{2192} Output: intent = "accountQuery"
            - Input: "Pay my electric bill on July 10" \u{2192} Output: intent = "payment"

            Output: 
            - intent = "<intent identifier>"
            """
        }
    }

    public init() {
        let deeplinkOptions = Self.deeplinkOptions
        let deeplinkMapping = Self.deeplinkMapping(deeplinkOptions)

        let paymenttool = CapturePaymentIntentTool()

        self.session = LanguageModelSession(
            tools: [paymenttool],
            instructions: Self.instructions(deeplinkMapping)
        )
    }

    @MainActor
    public func captureIntent(_ text: String) async throws -> UserIntent {
        let promt = Prompt({
            """
            Extract the user's intent and details for this request:
            \(text)
            """
        })
        let classified = try await session.respond(to: promt, generating: DeeplinkIntent.self, includeSchemaInPrompt: false, options: GenerationOptions(sampling: .greedy))
        print(classified.content.intent)
        print(String(describing: classified.content.paymentDetails?.formatedOutput))
        switch classified.content.intent {
        case .payment:
            if let pay = classified.content.paymentDetails?.formatedOutput {
                return .payment(pay)
            }
            fallthrough
        case .scheduleAppointment:
            return .scheduleAppointment
        case .checkFICO:
            return .checkFICO
        case .findATM:
            return .findATM
        case .cardManagement:
            // No action info available - pass empty string
            return .cardManagement
        case .accountQuery:
            return .accountQuery
        default:
            return .unknown
        }
    }

    public func prewarmSession() {
        session.prewarm()
    }
}

extension IntentClassifier {
    static var deeplinkOptions: [DeepLinkOption] {
        guard let url = Bundle.module.url(forResource: "DeeplinkMappings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([DeepLinkOption].self, from: data) else {
            debugPrint("DeeplinkMappings not found")
            return []
        }
        return decoded
    }

    static func deeplinkMapping(_ options: [DeepLinkOption]) -> String {
        options.map {
            "- \($0.intent): \($0.keywords.joined(separator: ", "))"
        }.joined(separator: "\n")
    }
}
