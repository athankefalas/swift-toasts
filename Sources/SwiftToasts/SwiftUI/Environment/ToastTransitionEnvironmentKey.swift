//
//  ToastTransitionEnvironmentKey.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

import SwiftUI

private struct ToastTransitionEnvironmentKey: EnvironmentKey {
    static let defaultValue: ToastTransition = .defaultTransition
}

public extension EnvironmentValues {
    
    internal(set) var toastTransition: ToastTransition {
        get { self[ToastTransitionEnvironmentKey.self] }
        set { self[ToastTransitionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Applies the given transition when inserting and removing toasts.
    /// - Parameter transition: The transition to use.
    /// - Returns: A modified view.
    func toastTransition(
        _ transition: ToastTransition
    ) -> some View {
        self.environment(\.toastTransition, transition)
    }
}
