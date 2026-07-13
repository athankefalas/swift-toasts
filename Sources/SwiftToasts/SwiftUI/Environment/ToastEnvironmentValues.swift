//
//  ToastEnvironmentValues.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 27/7/25.
//

import Foundation

public struct ToastEnvironmentValues {
    let toastStyle: AnyToastStyle
    let toastTransition: ToastTransition
    let toastInteractiveDismissEnabled: Bool
    let toastAccessibilityOptions: ToastAccessibilityOptions
    
    public init(
        toastTransition: ToastTransition = .defaultTransition,
        toastInteractiveDismissEnabled: Bool = true,
        toastAccessibilityOptions: ToastAccessibilityOptions = ToastAccessibilityOptions()
    ) {
        self.toastStyle = AnyToastStyle(.automatic)
        self.toastTransition = toastTransition
        self.toastInteractiveDismissEnabled = toastInteractiveDismissEnabled
        self.toastAccessibilityOptions = toastAccessibilityOptions
    }
    
    public init<Style: ToastStyle>(
        toastStyle: Style,
        toastTransition: ToastTransition = .defaultTransition,
        toastInteractiveDismissEnabled: Bool = true,
        toastAccessibilityOptions: ToastAccessibilityOptions = ToastAccessibilityOptions()
    ) {
        self.toastStyle = toastStyle.erased()
        self.toastTransition = toastTransition
        self.toastInteractiveDismissEnabled = toastInteractiveDismissEnabled
        self.toastAccessibilityOptions = toastAccessibilityOptions
    }
}
