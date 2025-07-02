//
//  InputModel.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation

struct InputModel: Codable {
    let category: String
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
