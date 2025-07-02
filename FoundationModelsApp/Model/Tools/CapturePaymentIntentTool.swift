//
//  CapturePaymentIntentTool.swift
//  OnDeviceLLMModel
//
//  Created by Praveen Prabhakar on 6/30/25.
//

import Foundation
import FoundationModels

@Observable
final class CapturePaymentIntentTool: Tool {
    let name = "capturePaymentIntent"
    let description = """
            You're responsible for extracting structured payment instructions from the user's message.
            Any user request involving sending money, making a bill payment, or paying utilities should always use the capturePaymentIntent tool.
            Always format any date in 'dd/MM/yyyy'.
            Do not assume any values.
            
            Look for details like:
            - type ("Send, recevie, or billPayment" the payment)
            - recipient (who is being paid)
            - reason (what the payment is for)
            - amount (in dollars and cents)
            - date (if the user mentions something like 'tomorrow', 'July 4', '10 days' or 'next Friday')
            - method (if available) (e.g., credit card, savings, checking)
            """

    @Generable
    struct Arguments {

        @Guide(description: "Send, recevie, or billPayment the payment.")
        let type: PaymentType

        @Guide(description: "Person or entity receiving the payment.")
        let recipient: String?

        @Guide(description: "Purpose of the payment.")
        let reason: String?

        @Guide(description: "Dollar and cent amount.")
        let amount: Currency?

        @Guide(description: "Payment date string (use today as reference), e.g., 'in 10 days', 'July 28', or 'next Monday' (Format e.g. '07/04/2024').")
        let date: String?

        @Guide(description: "Payment method, if specified.")
        let method: PaymentMethod?
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        var value = "Payment"
        if let amount = arguments.amount?.formatted {
            value.append(" of \(amount) dollars")
        }
        if let recipient = arguments.recipient {
            value.append(" to \(recipient)")
        }
        if let reason = arguments.reason {
            value.append(" for \(reason)")
        }
        if let dateString = Date.parseRelativeDate(arguments.date) {
            value.append(" on \(dateString)")
        }
        if let method = arguments.method {
            value.append(", using \(method.rawValue)")
        }
        return ToolOutput(value)
    }
}

@Generable
struct PaymentIntent: Equatable {
    let type: PaymentType
    let recipient: String
    let reason: String?
    let amount: Currency
    let date: String?
    let method: PaymentMethod?
}

extension PaymentIntent {
    var debugDescription: String {
        """
PaymentOutput(
    type: \(type)
    recipient: \(recipient)
    reason: \(reason ?? "nil")
    amount: \(amount)
    method: \(method ?? .unknown)
    date: \(Date.parseRelativeDate(date) ?? "nil")
)
"""
    }
}

@Generable
struct Currency: Equatable {
    let dollars: Int
    let cents: Int

    var formatted: String {
        "$\(dollars).\(String(format: "%02d", cents))"
    }
}

@Generable
enum PaymentMethod: String, CaseIterable {
    case unknown
    case creditCard
    case saving
    case checking
}

@Generable
enum PaymentType: String, CaseIterable {
    case unknown
    case send, recevie, billPayment
}
