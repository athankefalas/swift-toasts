//
//  ToastBackgroundInteractionEnabledEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 16/7/26.
//

import SwiftUI

struct ToastBackgroundInteractionEnabledEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

public extension EnvironmentValues {
    
    /// Controls whether the background content behind a presented `Toast` is interactive.
    internal(set) var toastBackgroundInteractionEnabled: Bool {
        get { self[ToastBackgroundInteractionEnabledEnvironmentKey.self] }
        set { self[ToastBackgroundInteractionEnabledEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Controls whether the background content behind a presented `Toast` is interactive.
    /// - Parameter disabled: A Boolean value that determines whether the content behind a Toast is interactive.
    /// - Returns: A modified view.
    func toastBackgroundInteractionDisabled(
        _ disabled: Bool
    ) -> some View {
        self.environment(\.toastBackgroundInteractionEnabled, !disabled)
    }
}
