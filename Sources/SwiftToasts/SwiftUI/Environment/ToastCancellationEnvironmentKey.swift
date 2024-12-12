//
//  ToastCancellationEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

private struct ToastCancellationEnvironmentKey: EnvironmentKey {
    public static let defaultValue = ToastCancellation.automatic
}

public extension EnvironmentValues {
    
    /// The preferred toast cancellation policy.
    internal(set) var toastCancellation: ToastCancellation {
        get { self[ToastCancellationEnvironmentKey.self] }
        set { self[ToastCancellationEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Controls the toast cancellation policy in this View and it's descendants.
    /// - Parameter cancellationPolicy: The preferred cancellation policy.
    /// - Returns: A modified view.
    func toastCancellation(
        _ cancellationPolicy: ToastCancellation
    ) -> some View {
        self.environment(\.toastCancellation, cancellationPolicy)
    }
}
