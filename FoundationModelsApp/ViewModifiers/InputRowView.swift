//
//  SampleInputTable.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct InputRowView: View {
    let samples: [InputModel]
    @Binding var userInput: String
    let closure: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(samples, id: \.title) { sample in
                Button(action: {
                    userInput = sample.title
                    closure()
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
