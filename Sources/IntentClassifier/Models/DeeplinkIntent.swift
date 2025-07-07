//
//  DeeplinkIntent.swift
//  BankingIntentClassifier
//
//  Created by Praveen Prabhakar on 7/2/25.
//

import Foundation
import FoundationModels

@Generable
struct DeeplinkIntent: Equatable {
    @Guide(description: "An enumeration of user intent identifiers.",
           .anyOf(IntentKeywordMappingProvider.deeplinkCategory))
    let intent: String

    @Guide(description: "Details mentioned in the intent")
    let details: ExtractIntentDetailsTool.Arguments?
}
