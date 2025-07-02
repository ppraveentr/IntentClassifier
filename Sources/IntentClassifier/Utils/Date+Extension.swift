//
//  Date+Extension.swift
//  BankingIntentClasifier
//
//  Created by Praveen Prabhakar on 6/30/25.
//

import Foundation
import NaturalLanguage
import SwiftUI

/*
 • The current code relies on system-provided parsers, which aren’t robust for all types of relative date input.
 • If you want to handle phrases like "in 10 days", you’ll need to add explicit pattern-matching logic for them or use a more advanced NLP date parser.

 Has other values (e.g., "as soon as possible", "whenever", "after lunch")
 • These won’t match any of the explicit date formats or the "in N days" logic.
 • If NSDataDetector cannot extract a date from these phrases, the method returns nil.
 • Recognized formats: Explicit date strings, "in N days/weeks/months/years", and some natural language phrases.
 • Not recognized: Very abstract or indirect phrasing, or empty input.
 */
public extension Date {
    static func parseRelativeDate(_ input: String?) -> Date? {
        guard let input, let date = parsedDate(from: input) else { return nil }
        return formatter.date(from: date)

    }

    var stringDate: String? {
        return Self.formatter.string(from: self)
    }

    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }
}

private extension Date {

    static var timezone: TimeZone {
        .current
    }

    static var calendar: Calendar {
        Calendar(identifier: .gregorian)
    }

    // MARK: - Precompiled Regex Patterns for Relative Dates

    private static let relativeRegexes: [NSRegularExpression] = [
        try! NSRegularExpression(pattern: #"(?:in\s+)?(\d+)\s+(day|days|week|weeks|month|months|year|years)"#),
        try! NSRegularExpression(pattern: #"after\s+(\d+)\s+(day|days|week|weeks|month|months|year|years)"#),
        try! NSRegularExpression(pattern: #"(\d+)\s+(day|days|week|weeks|month|months|year|years)\s+from now"#)
    ]

    private static let nextRegex: NSRegularExpression = try! NSRegularExpression(pattern: #"next\s+(week|month|year)"#)

    // MARK: - Extracts numeric and unit components from a text using a precompiled regex
    private static func extractRelativeComponents(using regex: NSRegularExpression, in text: String) -> (Int, String)? {
        let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsrange),
              match.numberOfRanges >= 3,
              let numRange = Range(match.range(at: 1), in: text),
              let unitRange = Range(match.range(at: 2), in: text),
              let num = Int(text[numRange]) else { return nil }
        let unit = String(text[unitRange])
        return (num, unit)
    }

    /// Returns the next occurrence of the given weekday name after the specified date.
    /// - Parameters:
    ///   - weekdayName: The full name of the weekday (e.g., "monday", "tuesday").
    ///   - date: The reference date from which to find the next weekday.
    /// - Returns: The next date matching the given weekday name, or nil if the name is invalid.
    static func nextWeekday(named weekdayName: String, from date: Date) -> Date? {
        let lowercasedWeekday = weekdayName.lowercased()

        // Weekday symbols from the calendar start with Sunday at index 1
        let weekdays = calendar.weekdaySymbols.map { $0.lowercased() }
        guard let weekdayIndex = weekdays.firstIndex(of: lowercasedWeekday) else {
            return nil
        }

        let targetWeekday = weekdayIndex + 1 // calendar weekday indexes are 1-based (Sunday=1)

        let components = calendar.dateComponents([.weekday, .hour, .minute, .second], from: date)
        let currentWeekday = components.weekday!

        // Calculate days until the next target weekday
        var daysToAdd = targetWeekday - currentWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7
        }

        return calendar.date(byAdding: .day, value: daysToAdd, to: date)
    }
    
    // --- SMARTER PARSING IMPROVEMENTS ---
    // 1. Support partial weekday names (first 3+ chars)
    // 2. Recognize patterns like "next Mon", "fri", "tomorrow at 8am", "next wednesday at 18:00", "in 2 weeks on monday"
    // 3. Improved fallback and robust defensive parsing
    //
    // Apply in the Date extension. Do not change API signatures.

    // 1. Add a helper to match and resolve partial weekday strings.
    private static func resolveWeekdayName(_ input: String) -> String? {
        let weekdays = calendar.weekdaySymbols.map { $0.lowercased() }
        // Accept full or partial (first 3+) match
        let lcInput = input.lowercased().trimmingCharacters(in: .whitespaces)
        if let match = weekdays.first(where: { $0.hasPrefix(lcInput) }) {
            return match
        }
        // Try 3-letter symbols
        let shortWeekdays = calendar.shortWeekdaySymbols.map { $0.lowercased() }
        if let idx = shortWeekdays.firstIndex(where: { $0.hasPrefix(lcInput.prefix(3)) }) {
            return weekdays[idx]
        }
        return nil
    }

    /// Parses a date from various string formats including explicit dates, relative phrases (e.g., "in 3 days"),
    /// some natural language expressions, explicit keywords (e.g., "tomorrow", "the day after tomorrow"),
    /// and weekday names (e.g., "monday", "tuesday").
    ///
    /// - Parameter string: Input date string to parse.
    /// - Returns: Parsed date string formatted as "dd/MM/yyyy" if recognized, otherwise `nil`.
    static func parsedDate(from string: String?) -> String? {
        guard let string = string else { return nil }

        // MARK: Attempt explicit date formats
        let formats = [
            "MMMM d", "MMM d", "M/d/yyyy", "yyyy-MM-dd", "MMMM d, yyyy",
            "MMMM d yyyy", "EEEE", "EEEE h a", "h:mm a", "h a", "d MMM yyyy", "MM/dd/yy", "yyyy-MM-dd HH:mm:ss",
            "mm/dd/yyyy HH:mm:ss", "mm/dd/yyyy", "yyyy-MM-dd HH:mm"
        ]

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return formatter.string(from: date)
            }
        }

        let lowercased = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // MARK: Check relative date patterns with number and unit
        for regex in relativeRegexes {
            if let (num, unit) = extractRelativeComponents(using: regex, in: lowercased) {
                var comp = DateComponents()
                switch unit {
                case "day", "days": comp.day = num
                case "week", "weeks": comp.day = num * 7
                case "month", "months": comp.month = num
                case "year", "years": comp.year = num
                default: break
                }
                if let date = calendar.date(byAdding: comp, to: Date()) {
                    return formatter.string(from: date)
                }
            }
        }

        // MARK: Check "next <unit>" pattern
        let nsrangeNext = NSRange(lowercased.startIndex..<lowercased.endIndex, in: lowercased)
        if let match = nextRegex.firstMatch(in: lowercased, options: [], range: nsrangeNext),
           match.numberOfRanges == 2,
           let unitRange = Range(match.range(at: 1), in: lowercased) {
            let unit = String(lowercased[unitRange])
            var comp = DateComponents()
            switch unit {
            case "week": comp.day = 7
            case "month": comp.month = 1
            case "year": comp.year = 1
            default: break
            }
            if let date = calendar.date(byAdding: comp, to: Date()) {
                return formatter.string(from: date)
            }
        }

        // MARK: Handle explicit keywords for common relative dates
        switch lowercased {
        case "tomorrow":
            if let date = calendar.date(byAdding: .day, value: 1, to: Date()) {
                return formatter.string(from: date)
            }
        case "yesterday":
            if let date = calendar.date(byAdding: .day, value: -1, to: Date()) {
                return formatter.string(from: date)
            }
        case "today":
            return formatter.string(from: Date())
        case "now", "asap", "as soon as possible", "immediately":
            return formatter.string(from: Date())
        case "whenever":
            return nil
        case "the day after tomorrow":
            if let date = calendar.date(byAdding: .day, value: 2, to: Date()) {
                return formatter.string(from: date)
            }
        case "the day before yesterday":
            if let date = calendar.date(byAdding: .day, value: -2, to: Date()) {
                return formatter.string(from: date)
            }
        default:
            // Check if the string matches a weekday name
            if let nextWeekdayDate = nextWeekday(named: lowercased, from: Date()) {
                return formatter.string(from: nextWeekdayDate)
            }
        }

        // MARK: Fallback to NSDataDetector for other natural language date detection
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) {
            let range = NSRange(string.startIndex..., in: string)
            if let match = detector.firstMatch(in: string, options: [], range: range)?.date {
                return formatter.string(from: match)
            }
        }

        // No recognized date found
        return nil
    }
}
