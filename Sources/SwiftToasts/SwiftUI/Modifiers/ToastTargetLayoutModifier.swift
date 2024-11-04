//
//  ToastTargetLayoutModifier.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

private struct ToastTargetLayoutModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        ToastPresenterReader { presenterProxy in
            content
                .environment(\.toastPresenter, presenterProxy)
        }
    }
}

public extension View {
    
    /// Marks this `View` hierarchy as the target for presenting toasts.
    /// - Returns: A modified view.
    func toastTargetLayout() -> some View {
        modifier(ToastTargetLayoutModifier())
    }
}
