// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Description: A Swift package for classifying user's input to banking-related intents using Apple's FoundationModel.
// Homepage: https://github.com/ppraveentr/BankingIntentClassifier
// Repository: https://github.com/ppraveentr/BankingIntentClassifier

import PackageDescription

let package = Package(
    name: "BankingIntentClassifier",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IntentClassifier",
            targets: ["IntentClassifier"]
        ),
    ],
    targets: [
        .target(
            name: "IntentClassifier",
            resources: [
                .process("Resources/DeeplinkMappings.json")
            ]
        ),
        .testTarget(
            name: "IntentClassifierTests",
            dependencies: ["IntentClassifier"]
        ),
    ]
)
