//
//  SampleInputView.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct SampleInputView: View {
    @State private var isSampleGenerating: Bool = false
    @State private var isSampleInputsExpanded: Bool = true
    @State private var expandedCategory: String? = nil
    @State private var sampleInputs: [InputModel] = InputModel.loadFromBundle()

    var userInput: Binding<String>
    let inputSelectionClosure: () -> Void

    private var grouped: [String: [InputModel]] {
        Dictionary(grouping: sampleInputs, by: { $0.category })
    }
    
    private var sortedCategories: [String] {
        grouped.keys.sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            GenerateButton(title: "Generate Sample", imageName: "arrow.clockwise", showButton: $isSampleGenerating) {
                updateSampleList()
            }

            button(isExpanded: isSampleInputsExpanded, text: "Sample Inputs") {
                isSampleInputsExpanded.toggle()
            }

            if isSampleInputsExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(sortedCategories, id: \.self) { category in
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
                                InputRowView(samples: grouped[category] ?? [], userInput: userInput, closure: inputSelectionClosure)
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
        .onAppear {
            updateSampleList()
        }
        .padding(.horizontal)
    }

    func updateSampleList() {
        Task {
            isSampleGenerating = true
            if let model = try? await IntentSampleGenerator().generateSamples(), !model.isEmpty {
                sampleInputs = model
            }
            isSampleGenerating = false
        }
    }

    @ViewBuilder
    func button(isExpanded: Bool, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.accentColor)
                    .padding(.leading, 4)
                Text(splitCamelCase(text))
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonRowStyle()
    }

    private func splitCamelCase(_ text: String) -> String {
        let pattern = "([a-z])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.count)
        let modString = regex?.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "$1 $2") ?? text
        return modString.prefix(1).uppercased() + modString.dropFirst()
    }

}
