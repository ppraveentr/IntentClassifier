//
//  SpinnerView.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

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
