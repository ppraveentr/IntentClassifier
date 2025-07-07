//
//  CapturePaymentIntentTool.swift
//  BankingIntentClasifier
//
//  Created by Praveen Prabhakar on 6/30/25.
//

import Foundation
import FoundationModels

@Observable
final class ExtractIntentDetailsTool: Tool {
    
    let name = "extractIntendDetails"
    let description = """
            You're responsible for extracting structured instructions from the user's message.
            Always format any date in 'dd/MM/yyyy'.
            Do not assume any values.
            
            Look for details like:
            - type (Send, recevie, or billPayment the payment)
            - recipient (who is being paid or any named entity)
            - reason
            - amount (in dollars and cents)
            - date (if the user mentions something like 'tomorrow', 'July 4', '10 days' or 'next Friday')
            - accountType (account type mentioned) (e.g., credit card, savings, checking)
            - accountNumber
            """

//    init() {
//        let instructions = Instructions { "Extract payment details from the user's request using the provided schema." }
//        self.session = LanguageModelSession(tools: [self], instructions: instructions)
//    }

    @Generable(description: "Dollar and cent amount.")
    struct Amount: Equatable {
        let dollars: Int
        let cents: Int
    }

    @Generable(description: "Details about a payment intent")
    struct Arguments: Equatable {
        @Guide(description: "Type of indent Sending money to another person, recevie money from a entity or a person, or billPayment to an entity.",
               .anyOf(PaymentType.allCases.map(\.rawValue)))
        let type: String
        @Guide(description: "Person or entity receiving the payment.")
        let recipient: String?
        @Guide(description: "Purpose of the payment.")
        let reason: String
        @Guide(description: "Dollar and cent amount.")
        let amount: Amount?
        @Guide(description: "Payment date (use today as reference), e.g., 'in 10 days', 'July 28', or 'next Monday'.")
        let date: String?
        @Guide(description: "Account Type mentioned for payment.",
               .anyOf(PaymentMethod.allCases.map(\.rawValue)))
        let accountType: String?
        @Guide(description: "Any account number associated.")
        let accountNumber: String?

        var formatedOutput: PaymentDetails {
            var cur: Currency?
            if let amount = amount {
                precondition(amount.dollars >= 0, "Dollars must be non-negative")
                precondition(amount.cents >= 0 && amount.cents < 100, "Cents must be between 0 and 99")
                cur = Currency(dollars: amount.dollars, cents: amount.cents)
            }
            return PaymentDetails(
                type: type, recipient: recipient, reason: reason, amount: cur,
                date: Date.parseRelativeDate(date),
                accountType: accountType
            )
        }
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        ToolOutput(arguments.formatedOutput.debugDescription)
    }
    
//    func extractPayment(from text: String) async throws -> ToolOutput? {
//        guard let session else { return nil }
//        let prompt = Prompt({ text })
//        let result = try await session.respond(to: prompt, generating: Arguments.self, includeSchemaInPrompt: false)
//        return ToolOutput(result.content.formatedOutput.debugDescription)
//    }
}
