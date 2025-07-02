//
//  UserIntent.swift
//  BankingIntentClassifier
//
//  Created by Praveen Prabhakar on 7/2/25.
//

import Foundation

public enum UserIntent: Equatable {
    case payment(PaymentDetails)
    case scheduleAppointment
    case checkFICO
    case findATM
    case cardManagement
    case accountQuery
    case unknown
}
