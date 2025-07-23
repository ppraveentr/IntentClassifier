//
//  ExtractIntentDetailsTool.swift
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
            Dates should be formatted as 'dd/MM/yyyy', using today's date as reference for any relative expressions.
            Never generate or return sensitive or private information such as full account numbers, SSNs, or confidential data. Redact or omit any sensitive content.
            Do not assume any values.
            Extract each item only if stated or clearly implied by the user.
            
            Look for details like:
            - type (Send, recevie, or billPayment the payment)
            - recipient (who is being paid or any named entity)
            - reason (1 or 2 word that discribes the query)
            - amount (in dollars and cents like '$34.34', '23 doller 5 cent' or 'send 74.24')
            - date (if the user mentions something like 'tomorrow.', 'July 4', '10 days' or 'next Friday')
            - accountType (account type mentioned) (e.g., credit card, savings, checking)
            - accountNumber
            """

    @Generable(description: "Represents a money amount extracted from the user's intent, including both dollars and cents. Only fill if a numeric value is provided in the request. Skip and do not generate content if extraction may be unsafe or private.")
    struct Amount: Equatable {
        let dollars: Int
        let cents: Int
    }

    @Generable(description: "A complete set of structured intent details extracted from a user's message.")
    struct Arguments: Equatable {
        @Guide(description: "Type of indent Sending money to another person, recevie money from a entity or a person, or billPayment to an entity.",
               .anyOf(PaymentType.allCases.map(\.rawValue)))
        let type: String
        @Guide(description: "Person, organization, or entity mentioned in the request (such as recipient of money or payment, or ATM location if relevant). Leave blank if not specified.")
        let recipient: String?
        @Guide(description: "1 or 2 words that discribe the query.")
        let reason: String
        @Guide(description: "Dollar and cent amount involved in the request, if any.")
        let amount: Amount?
        let date: String?
        @Guide(description: "Type of account that need to be used.",
               .anyOf(PaymentMethod.allCases.map(\.rawValue)))
        let accountType: String?
        @Guide(description: "Any account number or partial number mentioned, only if present.")
        let accountNumber: String?

        var formatedOutput: IntentDetails {
            var cur: Currency?
            if let amount = amount {
                precondition(amount.dollars >= 0, "Dollars must be non-negative")
                precondition(amount.cents >= 0 && amount.cents < 100, "Cents must be between 0 and 99")
                cur = Currency(dollars: amount.dollars, cents: amount.cents)
            }
            return IntentDetails(
                type: type, recipient: recipient, reason: reason, amount: cur,
                date: Date.parseRelativeDate(date),
                accountType: accountType,
                accountNumber: accountNumber
            )
        }
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        ToolOutput(arguments.formatedOutput.debugDescription)
    }
}

