//
//  ToastInteractiveDismissEnabledEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 27/7/25.
//

import SwiftUI

private struct ToastInteractiveDismissEnabledEnvironmentKey: EnvironmentKey {
    public static let defaultValue = true
}

public extension EnvironmentValues {
    
    /// Controls whether a `Toast` can be interactively dismissed.
    internal(set) var toastInteractiveDismissEnabled: Bool {
        get { self[ToastInteractiveDismissEnabledEnvironmentKey.self] }
        set { self[ToastInteractiveDismissEnabledEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Controls whether a Toast can be interactively dismissed.
    /// - Parameter disabled: A Boolean value that determines whether a Toast. can be interactively dismissed.
    /// - Returns: A modified view.
    func toastInteractiveDismissDisabled(
        _ disabled: Bool
    ) -> some View {
        self.environment(\.toastInteractiveDismissEnabled, !disabled)
    }
}
