//
//  DeepLinkOption.swift
//  BankingIntentClassifier
//
//  Created by Praveen Prabhakar on 7/2/25.
//

import Foundation

struct DeepLinkOption: Equatable, Decodable {
    let intent:  UserIntentIdentifier
    let keywords: [String]
}
