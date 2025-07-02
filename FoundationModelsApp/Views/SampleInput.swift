//
//  SampleInput.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct SampleInput: Codable {
    let category: String
    let title: String

    static func loadFromBundle() -> [SampleInput] {
        guard let url = Bundle.main.url(forResource: "SampleInputs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let samples = try? JSONDecoder().decode([SampleInput].self, from: data) else {
            return []
        }
        return samples
    }
}


struct SampleInputView: View {
    @State private var isSampleInputsExpanded: Bool = true
    @State private var expandedCategories: Set<String> = []

    var userInput: Binding<String>

    var body: some View {
        let sampleInputs = SampleInput.loadFromBundle()
        let grouped = Dictionary(grouping: sampleInputs, by: { $0.category })
        let sortedCategories = grouped.keys.sorted()
        
        DisclosureGroup(
            isExpanded: $isSampleInputsExpanded,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(sortedCategories, id: \.self) { category in
                        let isExpanded = Binding<Bool>(
                            get: { expandedCategories.contains(category) },
                            set: { expanded in
                                if expanded {
                                    expandedCategories.insert(category)
                                } else {
                                    expandedCategories.remove(category)
                                }
                            }
                        )
                        DisclosureGroup(
                            isExpanded: isExpanded,
                            content: {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(grouped[category] ?? [], id: \.title) { sample in
                                        Text(sample.title)
                                            .onTapGesture {
                                                userInput.wrappedValue = sample.title
                                            }
                                            .padding(.vertical, 2)
                                    }
                                }
                                .padding(.horizontal, 8)
                            },
                            label: {
                                button(isExpanded: isExpanded, text: category)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            },
            label: {
                button(isExpanded: $isSampleInputsExpanded, text: "Sample Imputs")
            }
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    func button(isExpanded: Binding<Bool>, text: String) -> some View {
        Button(action: {
            isExpanded.wrappedValue.toggle()
        }) {
            HStack {
                Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                    .foregroundColor(.accentColor)
                Text(text)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
