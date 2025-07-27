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
    
    public init(
        toastTransition: ToastTransition = .defaultTransition,
        toastInteractiveDismissEnabled: Bool = true
    ) {
        self.toastStyle = AnyToastStyle(PlainToastStyle())
        self.toastTransition = toastTransition
        self.toastInteractiveDismissEnabled = toastInteractiveDismissEnabled
    }
    
    public init<Style: ToastStyle>(
        toastStyle: Style,
        toastTransition: ToastTransition = .defaultTransition,
        toastInteractiveDismissEnabled: Bool = true
    ) {
        self.toastStyle = toastStyle.erased()
        self.toastTransition = toastTransition
        self.toastInteractiveDismissEnabled = toastInteractiveDismissEnabled
    }
}
