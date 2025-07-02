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
    @State private var expandedCategory: String? = nil

    var userInput: Binding<String>
    
    private static var sampleInputs: [SampleInput] = {
        SampleInput.loadFromBundle()
    }()

    private static var grouped: [String: [SampleInput]] = {
        Dictionary(grouping: sampleInputs, by: { $0.category })
    }()

    private static var sortedCategories: [String] = {
        grouped.keys.sorted()
    }()

    var body: some View {
        VStack(alignment: .leading) {
            button(isExpanded: isSampleInputsExpanded, text: "Sample Inputs") {
                isSampleInputsExpanded.toggle()
            }

            if isSampleInputsExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Self.sortedCategories, id: \.self) { category in
                        let isExpanded = expandedCategory == category
                        VStack(alignment: .leading, spacing: 0) {
                            button(isExpanded: isExpanded, text: category) {
                                if expandedCategory == category {
                                    expandedCategory = nil
                                } else {
                                    expandedCategory = category
                                }
                            }

                            Spacer()
                                .frame(height: isExpanded ? 10 : 0)
                            if isExpanded {
                                SampleInputTable(samples: Self.grouped[category] ?? [], userInput: userInput)
                                    .padding(.horizontal, 8)
                                    .animation(.easeInOut, value: isExpanded)
                                    .background(.thinMaterial)
                            }
                        }
                        .cornerRadius(8)
                        .shadow(radius: 1)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    func button(isExpanded: Bool, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.accentColor)
                    .padding(.leading, 4)
                Text(text)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .font(.headline)
        .foregroundColor(.primary)
        .opacity(0.9)
        .padding(8)
        .background(.thinMaterial)
        .cornerRadius(8)
        .shadow(radius: 1)
        .padding(.vertical, 4)
    }
}

struct SampleInputTable: View {
    let samples: [SampleInput]
    @Binding var userInput: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(samples, id: \.title) { sample in
                Button(action: {
                    userInput = sample.title
                }) {
                    Text(sample.title)
                        .font(.body)
                        .foregroundColor(userInput == sample.title ? .accentColor : .primary)
                    .padding(8)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 1)
            }
        }
    }
}

private struct SampleRowStyle: ViewModifier {
    let selected: Bool
    
    func body(content: Content) -> some View {
        content
            .fontWeight(selected ? .semibold : .regular)
            .foregroundColor(selected ? .accentColor : .primary)
            .background(selected ? Color.accentColor.opacity(0.07) : Color.clear)
            .contentShape(Rectangle())
            .padding(.vertical, 2)
            .padding(.leading, 6)
    }
}

extension View {
    func sampleRowStyle(selected: Bool) -> some View {
        self.modifier(SampleRowStyle(selected: selected))
    }
}
