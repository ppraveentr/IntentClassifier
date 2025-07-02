//
//  GenerateButton.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct GenerateButton: View {
    var showButton: Binding<Bool>
    let closure: () async throws -> Void

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            SpinnerView(isShowing: showButton)
            Spacer().frame(maxWidth: 20)
            Button {
                Task { @MainActor in
                    try await closure()
                }
            }
            label: {
                Label("Find Intent", systemImage: "sparkles")
                    .fontWeight(.bold)
                    .padding()
            }
            .buttonStyle(.bordered)
            .padding()
            .transition(.opacity)
            .opacity(showButton.wrappedValue ? 0 : 1)
            Spacer()
        }
        .animation(
            .easeInOut(duration: 0.5),
            value: showButton.wrappedValue
        )
    }
}
