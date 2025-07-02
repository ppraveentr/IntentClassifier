//
//  GenerateButton.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct GenerateButton: View {
    var title: String
    var imageName: String = "sparkles"

    var showButton: Binding<Bool>
    let closure: () async throws -> Void

    var body: some View {
        HStack(alignment: .center) {
            Button {
                Task { @MainActor in
                    try await closure()
                }
            } label: {
                SpinnerView(isShowing: showButton)
                    .frame(width: 24, height: 24)
                    .padding(.leading, 8)
                Label(title, systemImage: imageName)
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                    .padding()
            }
            .disabled(showButton.wrappedValue)
            .buttonRowStyle()
        }
        .animation(
            .easeInOut(duration: 0.5),
            value: showButton.wrappedValue
        )
    }
}
