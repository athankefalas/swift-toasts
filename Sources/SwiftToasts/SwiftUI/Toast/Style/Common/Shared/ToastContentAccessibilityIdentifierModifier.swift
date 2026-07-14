//
//  ToastContentAccessibilityIdentifierModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 14/7/26.
//

import SwiftUI

struct ToastContentAccessibilityIdentifierModifier: ViewModifier {
    @Environment(\.toastAccessibilityOptions.accessibilityIdentifiers)
    private var accessibilityIdentifiers
    
    let keyPath: KeyPath<ToastAccessibilityOptions.ToastContentAccessibilityIdentifiers, String?>
    
    init(keyPath: KeyPath<ToastAccessibilityOptions.ToastContentAccessibilityIdentifiers, String?>) {
        self.keyPath = keyPath
    }
    
    func body(content: Content) -> some View {
        content.fallbackAccessibilityIdentifier(accessibilityIdentifiers[keyPath: keyPath] ?? "")
    }
}

extension View {
    
    func toastContentAccessibilityId(
        _ keyPath: KeyPath<ToastAccessibilityOptions.ToastContentAccessibilityIdentifiers, String?>
    ) -> some View {
        self.modifier(ToastContentAccessibilityIdentifierModifier(keyPath: keyPath))
    }
}
