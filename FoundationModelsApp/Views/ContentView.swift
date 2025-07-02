//
//  ContentView.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import IntentClassifier
import SwiftUI

struct ContentView: View {
    @State private var userInput = "Send money to Zoe for 42.15 from checking in 10 days"
    @State private var outputText: String = ""
    @State private var isProcessing = false

    @State private var planner = IntentClassifier()
    @State private var generatedIntend: UserIntent = .unknown

    @State private var sampleInputs: [SampleInput] = []

    var body: some View {
        VStack(spacing: 20) {

            TextField("e.g. \(String(describing: sampleInputs.first?.title))", text: $userInput)
                .textFieldStyle(.roundedBorder)

            GenerateButton(showButton: $isProcessing) {
                Task {
                    await parseRequest()
                }
            }
            .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isProcessing)

            HStack(alignment: .top) {
                VStack {
                    SampleInputView(userInput: $userInput)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)

                VStack(alignment: .leading) {
                    if outputText.isEmpty {
                        Text("No Output")
                            .foregroundColor(.secondary)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(outputText)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
            }

            Spacer()
        }.onAppear {
            Task {
                if sampleInputs.isEmpty {
                    sampleInputs = SampleInput.loadFromBundle()
                }
                isProcessing = true
                planner.prewarm()
                isProcessing = false
            }
        }
        .padding()
    }

    func parseRequest() async {
        isProcessing = true
        defer { isProcessing = false }
        generatedIntend = .unknown
        do {
            generatedIntend = try await planner.captureIntent(userInput)
            switch generatedIntend {
            case let .payment(pament):
                outputText = pament.debugDescription
            default:
                outputText = String(describing: generatedIntend)
            }
        } catch {
            outputText = "❌ Error: \(error.localizedDescription)"
        }
    }
}

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

struct SpinnerView: View {
    var isShowing: Binding<Bool>
    var body: some View {
        if isShowing.wrappedValue {
            HStack {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                Spacer()
            }
        }
    }
}
