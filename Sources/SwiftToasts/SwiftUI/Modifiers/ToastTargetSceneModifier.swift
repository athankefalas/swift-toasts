//
//  ToastTargetSceneModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

private struct ToastTargetSceneModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        ToastPresenterReader { presenterProxy in
            content
                .environment(\.toastPresenter, presenterProxy)
        }
    }
}

public extension View {
    
    /// Marks the scene of this `View` hierarchy as the target for presenting toasts.
    /// - Note: If scene level presentation is not available in the current platform this modifier will have on effect.
    /// - Returns: A modified view.
    func toastTargetScene() -> some View {
        modifier(ToastTargetSceneModifier())
    }
}
