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
    @State private var outputError: Error?
    @State private var isProcessing = false
    @State private var intendClassifier = IntentClassifier()
    @State private var generatedIntend: (intent: String, details: IntentDetails?) = ("unknown", nil)
    @State private var sampleInputs: [InputModel] = []

    var body: some View {
        VStack(spacing: 20) {

            TextField("e.g. \(String(describing: sampleInputs.first?.title))", text: $userInput)
                .textFieldStyle(.roundedBorder)

            GenerateButton(title: "Find Intent", showButton: $isProcessing) {
                await generateIntent()
            }
            .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isProcessing)

            HStack(alignment: .top) {
                VStack {
                    SampleInputView(userInput: $userInput) {
                        Task {
                            await generateIntent()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)

                outputSection()
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
            }

            Spacer()
        }.onAppear {
            Task {
                if sampleInputs.isEmpty {
                    sampleInputs = InputModel.loadFromBundle()
                }
                isProcessing = true
                intendClassifier.prewarmSession()
                isProcessing = false
            }
        }
        .padding()
    }

    func generateIntent() async {
        isProcessing = true
        defer { isProcessing = false }
        generatedIntend = ("unknown", nil)
        outputError = nil
        do {
            generatedIntend = try await intendClassifier.captureIntent(userInput)
        } catch {
            outputError = error
        }
    }

    func formattedOutput() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Intent: \(generatedIntend.intent)").font(.headline)
                if let details = generatedIntend.details {
                    Group {
                        Text("Type: \(details.type.rawValue.capitalized)")
                        if let recipient = details.recipient { Text("Recipient: \(recipient)") }
                        if let reason = details.reason { Text("Reason: \(reason)") }
                        if let amount = details.amount { Text("Amount: \(amount.formatted)") }
                        if let date = details.date { Text("Date: \(date, style: .date)") }
                        Text("Method: \(details.accountType.rawValue.capitalized)")
                        if let acct = details.accountNumber { Text("Account #: \(acct)") }
                    }
                    .font(.subheadline)
                } else {
                    Text("nil").foregroundColor(.secondary)
                }
            }
            .padding(8)
            .background(Color.secondary)
            .cornerRadius(8)
        }
    }

    func outputSection() -> some View {
        VStack(alignment: .leading) {
            if isProcessing {
                Text("Calculating...")
                    .font(.body)
                    .multilineTextAlignment(.leading)
            } else if let error = outputError {
                Text("❌ Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            } else if generatedIntend.intent == "unknown" && !isProcessing {
                Text("No Output")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            } else if generatedIntend.intent != "unknown" {
                formattedOutput()
            }
        }
    }
}
