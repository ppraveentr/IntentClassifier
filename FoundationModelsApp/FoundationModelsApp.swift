/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main function for the FoundationModelsApp app.
*/

import IntentClassifier
import SwiftUI

@main
struct FoundationModelsApp: App {

    init() {
        loadJson()
    }

    func loadJson() {
        let url = Bundle.main.url(forResource: "DeeplinkMappings", withExtension: "json")
        do {
            try IntentKeywordMappingProvider.shared.loadMappingJson(from: url)
            debugPrint("IntentKeywordMappingProvider.loadIntendKeywordMappings")
        } catch {
            debugPrint("Failed to load intent keyword mappings: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
