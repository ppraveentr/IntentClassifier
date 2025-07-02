//
//  PaymentModelGenerator.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import FoundationModels

@Observable @MainActor
final class PaymentModelGenerator {
    private var session: LanguageModelSession

    static let instructions: Instructions = {
        Instructions {"""
        You are a payment extraction expert.
        You're responsible for extracting structured payment instructions from the user's message.
        Always use the CapturePaymentIntentTool to extact infomation.
        Always format any date in MM/DD/YYYY.
        Do not assume any values.
        """
        }
    }()

    init() {
        let tool = CapturePaymentIntentTool()
        self.session = LanguageModelSession(tools: [tool], instructions: Self.instructions)
    }

    @MainActor
    func captureIntent(_ text: String) async throws -> PaymentIntent {
        let paymentPrompt = Prompt({
            """
            Extract payment intent details for this request:
            \(text)
            """
        })
        let payment = try await session.respond(to: paymentPrompt,
                                                generating: PaymentIntent.self,
                                                includeSchemaInPrompt: false,
                                                options: GenerationOptions(sampling: .greedy))
        return payment.content
    }
}
