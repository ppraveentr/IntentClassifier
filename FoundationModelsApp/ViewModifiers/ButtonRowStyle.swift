//
//  ButtonRowStyle.swift
//  FoundationModelsApp
//
//  Created by Praveen Prabhakar on 7/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct ButtonRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .font(.headline)
            .foregroundColor(.primary)
            .opacity(0.9)
            .padding(8)
            .background(.thinMaterial)
            .cornerRadius(8)
            .shadow(radius: 1)
            .padding(.vertical, 4)
    }
}

extension View {
    func buttonRowStyle() -> some View {
        self.modifier(ButtonRowStyle())
    }
}
