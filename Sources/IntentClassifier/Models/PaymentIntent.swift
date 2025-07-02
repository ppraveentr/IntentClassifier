//
//  PaymentIntent.swift
//  BankingIntentClassifier
//
//  Created by Praveen Prabhakar on 7/2/25.
//

import Foundation
import FoundationModels

public enum PaymentMethod: String, CaseIterable {
    case unknown
    case creditCard, saving, checking
}

public enum PaymentType: String, CaseIterable {
    case unknown
    case send, recevie, billPayment
}

public struct PaymentDetails: Equatable {
    public let type: PaymentType
    public var recipient: String?
    public let reason: String?
    public let amount: Currency?
    public var date: Date?
    public let accountType: PaymentMethod

    public init(type: String, recipient: String? = nil, reason: String?, amount: Currency?, date: Date? = nil, accountType: String?) {
        self.type = PaymentType(rawValue: type) ?? .unknown
        self.recipient = recipient
        self.reason = reason
        self.amount = amount
        self.date = date
        self.accountType = PaymentMethod(rawValue: accountType ?? "") ?? .unknown
    }

    public var debugDescription: String {
        """
PaymentIntent(
    type: \(type)
    recipient: \(recipient)
    reason: \(reason ?? "nil")
    amount: \(amount?.formatted)
    method: \(accountType)
    date: \(date?.stringDate ?? "nil"))
)
"""
    }
}

public struct Currency: Equatable {
    public let dollars: Int
    public let cents: Int

    public var formatted: String {
        "$\(dollars).\(String(format: "%02d", cents))"
    }
}
