//
//  PaymentPlanner.swift
//  OnDeviceLLMModel
//
//  Created by Praveen Prabhakar on 6/30/25.
//

import Foundation
import Observation
import FoundationModels

@Generable
enum UserIntent: Equatable {
    case payment(PaymentIntent)
    case scheduleAppointment
    case checkFICO
    case findATM
    case cardManagement(action: String)
    case accountQuery(account: String)
    case unknown(raw: String)
}

@Observable @MainActor
final class IntentModelGenerator {
    private var session: LanguageModelSession

    static func instructions(_ deeplinkMapping: String) -> Instructions {
        Instructions {
            """
            You are an expert banking assistant. Your task is to classify a user's request into one of the supported intents listed below.
            The intent may be expressed using synonyms, paraphrases, or related phrases; always pick the *closest matching* intent, even if the words are not an exact match to the keywords.
            Do not create new intents, and do not ask for clarification.

            Supported intents:
            \(deeplinkMapping)

            For each user input, respond with intent identifier that only matches the best.

            Example inputs and expected outputs:
            - Input: "Send $50 to Mom tomorrow from checking" \u{2192} Output: intent = "payment"
            - Input: "Pay my Chase credit card bill on July 10" \u{2192} Output: intent = "payment"
            - Input: "What's my current FICO score?" \u{2192} Output: intent = "checkFICO"
            - Input: "Show me my credit score" \u{2192} Output: intent = "checkFICO"
            - Input: "Find the nearest ATM" \u{2192} Output: intent = "findATM"
            - Input: "Freeze my debit card" \u{2192} Output: intent = "cardManagement"
            - Input: "What's my checking balance?" \u{2192} Output: intent = "accountQuery"
            - Input: "Schedule an appointment with a banker next Friday" \u{2192} Output: intent = "scheduleAppointment"
            - Input: "Show me recent transactions in savings" \u{2192} Output: intent = "accountQuery"
            - Input: "Pay my electric bill on July 10" \u{2192} Output: intent = "payment"

            Output format: 
            - intent = "<intent identifier>"
            """
        }
    }

    init() {
        let deepLinktool = ClassifyDeeplinkTool()
        self.session = LanguageModelSession(
            tools: [deepLinktool],
            instructions: Self.instructions(deepLinktool.deeplinkMapping)
        )
    }

    @MainActor
    func captureIntent(_ text: String) async throws -> UserIntent {
        let promt = Prompt({
            """
            Extract the user's banking intent and details for this request:
            \(text)
            """
        })
        let classified = try await session.respond(to: promt, generating: ClassifiedDeeplinkIntent.self, includeSchemaInPrompt: false, options: GenerationOptions(sampling: .greedy))
        let intent = classified.content.intent
        
        switch intent {
        case .payment:
            let paymentSession = PaymentModelGenerator()
            let payment = try await paymentSession.captureIntent(text)
            return .payment(payment)
        case .scheduleAppointment:
            return .scheduleAppointment
        case .checkFICO:
            return .checkFICO
        case .findATM:
            return .findATM
        case .cardManagement:
            // No action info available - pass empty string
            return .cardManagement(action: "")
        case .accountQuery:
            return .accountQuery(account: "")
        case .unknown:
            return .unknown(raw: text)
        }
    }

    func prewarm() {
        session.prewarm()
    }
}

