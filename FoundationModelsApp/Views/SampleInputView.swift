//
//  SampleInputView.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct SampleInputView: View {
    @State private var isSampleInputsExpanded: Bool = true
    @State private var expandedCategory: String? = nil

    var userInput: Binding<String>
    
    private static var sampleInputs: [InputModel] = {
        InputModel.loadFromBundle()
    }()

    private static var grouped: [String: [InputModel]] = {
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
                                InputRowView(samples: Self.grouped[category] ?? [], userInput: userInput)
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
        .buttonRowStyle()
    }
}
