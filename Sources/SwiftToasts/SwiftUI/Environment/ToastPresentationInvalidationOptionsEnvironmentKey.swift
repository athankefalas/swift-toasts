//
//  ToastPresentationInvalidationOptionsEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 26/7/25.
//

import SwiftUI

private struct ToastPresentationInvalidationOptionsEnvironmentKey: EnvironmentKey {
    public static let defaultValue: ToastPresentationInvalidationOptions? = nil
}

public extension EnvironmentValues {
    
    /// The preferred toast cancellation policy.
    internal(set) var toastPresentationInvalidation: ToastPresentationInvalidationOptions? {
        get { self[ToastPresentationInvalidationOptionsEnvironmentKey.self] }
        set { self[ToastPresentationInvalidationOptionsEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Controls the presentation invalidation policy for presented Toasts in this View and it's descendants.
    /// - Parameter options: The preferred presentation invalidation options.
    ///                      Passing `nil` will set the Toast presentation invalidation options to the
    ///                      preferred invalidation options of each presentation source.
    /// - Note: These options may only partially apply based on the context of each presentation source.
    ///         For example, the `ToastButton` and the `task` modifier will ignore this value entirely as they
    ///         have no bound context to assign to each presentation, while the `toast(isPresented:)` and  the
    ///         `toast(item:)` modifiers will ignore some of these options since the presentation is partly controlled by their
    ///         binding parameters.
    /// - Returns: A modified view.
    func toastPresentationInvalidation(
        _ options: ToastPresentationInvalidationOptions?
    ) -> some View {
        self.environment(\.toastPresentationInvalidation, options)
    }
}
