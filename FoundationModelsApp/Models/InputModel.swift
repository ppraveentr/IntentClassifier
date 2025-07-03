//
//  InputModel.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import FoundationModels
import IntentClassifier

@Generable(description: "An example of user input for generating a sample response list for a given category")
struct InputModel: Codable {
    @Guide(description: "Category for describing the input text",
           .anyOf(IntentKeywordMappingProvider.deeplinkCategory))
    let category: String
    @Guide(description: "Sample user input in natural language format for the category")
    let title: String

    static func loadFromBundle() -> [InputModel] {
        guard let url = Bundle.main.url(forResource: "SampleInputs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let samples = try? JSONDecoder().decode([InputModel].self, from: data) else {
            return []
        }
        return samples
    }
}
