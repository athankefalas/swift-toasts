//
//  ToastDismissEnvironmentKey.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

private struct ToastDismissEnvironmentKey: EnvironmentKey {
    public static let defaultValue: ToastDismissAction? = nil
}

public extension EnvironmentValues {
    
    /// An action that can be used to dismiss a presented toast.
    internal(set) var toastDismiss: ToastDismissAction? {
        get { self[ToastDismissEnvironmentKey.self] }
        set { self[ToastDismissEnvironmentKey.self] = newValue }
    }
}
