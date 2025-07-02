//
//  UserIntentIdentifier.swift
//  BankingIntentClassifier
//
//  Created by Praveen Prabhakar on 7/2/25.
//

import Foundation
import FoundationModels

@Generable(description: "A list of all possible user intent identifiers")
enum UserIntentIdentifier: String, Codable, Equatable, CaseIterable {
    case payment
    case scheduleAppointment
    case checkFICO
    case findATM
    case cardManagement
    case accountQuery
    case unknown
}

@Generable
struct DeeplinkIntent: Equatable {
    @Guide(description: "An enumeration of user intent identifiers.")
    let intent: UserIntentIdentifier

    @Guide(description: "Payment intent details, if available.")
    let paymentDetails: CapturePaymentIntentTool.Arguments?
}
