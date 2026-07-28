//
//  ToastContentStyleEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI
import Combine

private struct ToastContentStyleEnvironmentKey: EnvironmentKey {
    @preconcurrency static var defaultValue: AnyToastContentStyle {
        AnyToastContentStyle(.standard)
    }
}

public extension EnvironmentValues {
    
    /// The style of ToastContenView components.
    fileprivate(set) var toastContentStyle: AnyToastContentStyle {
        get { self[ToastContentStyleEnvironmentKey.self] }
        set { self[ToastContentStyleEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    func toastContentStyle<Style: ToastContentStyle>(
        _ style: Style
    ) -> some View {
        self.environment(\.toastContentStyle, AnyToastContentStyle(style))
    }
}
