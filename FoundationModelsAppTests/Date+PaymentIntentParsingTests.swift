//
//  Date+PaymentIntentParsingTests.swift
//  FoundationModelsAppTests
//
//  Created by Praveen Prabhakar on 6/30/25.
//

import Foundation
@testable import FoundationModelsApp
import Testing

// Create a new file with Swift Testing macros to verify the smart parsing logic in Date.parsedDate(from:)
// Place in same module as CapturePaymentIntentTool.swift

@Suite("Date natural language parsing for payment intent")
struct PaymentIntentDateParsingTests {
    @Test("Standard explicit dates")
    func explicitFormats() async throws {
        #expect(Date.parsedDate(from: "07/04/2024") != nil)
        #expect(Date.parsedDate(from: "2024-07-04") != nil)
        #expect(Date.parsedDate(from: "July 4, 2024") != nil)
    }

    @Test("Relative day parsing")
    func relativeParsing() async throws {
        #expect(Date.parsedDate(from: "in 10 days") != nil)
        #expect(Date.parsedDate(from: "after 2 weeks") != nil)
        #expect(Date.parsedDate(from: "3 months from now") != nil)
    }

    @Test("Explicit keywords and smart phrases")
    func explicitKeywordParsing() async throws {
        #expect(Date.parsedDate(from: "tomorrow") != nil)
        #expect(Date.parsedDate(from: "today") != nil)
        #expect(Date.parsedDate(from: "the day after tomorrow") != nil)
        #expect(Date.parsedDate(from: "the day before yesterday") != nil)
        #expect(Date.parsedDate(from: "now") != nil)
        #expect(Date.parsedDate(from: "immediately") != nil)
    }

    @Test("Weekday smart parsing")
    func weekdayParsing() async throws {
        #expect(Date.parsedDate(from: "monday") != nil)
        #expect(Date.parsedDate(from: "next tuesday") != nil)
        #expect(Date.parsedDate(from: "fri") != nil)
        #expect(Date.parsedDate(from: "next Mon") != nil)
    }

    @Test("Time and weekday combos")
    func timeParsing() async throws {
        #expect(Date.parsedDate(from: "tomorrow at 8am") != nil)
        #expect(Date.parsedDate(from: "next wednesday at 14:30") != nil)
        #expect(Date.parsedDate(from: "in 2 weeks on monday") != nil)
    }

    @Test("Defensive parsing for ambiguous input")
    func ambiguousAndFallback() async throws {
        #expect(Date.parsedDate(from: "whenever") == nil)
        #expect(Date.parsedDate(from: "after lunch") == nil)
        #expect(Date.parsedDate(from: "as soon as possible") != nil)
    }
}

