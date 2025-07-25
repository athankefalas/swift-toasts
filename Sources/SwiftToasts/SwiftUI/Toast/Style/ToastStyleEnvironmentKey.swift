//
//  ToastStyleEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//


import SwiftUI
import Combine

private struct ToastStyleEnvironmentKey: EnvironmentKey {
    @preconcurrency static var defaultValue: AnyToastStyle {
        AnyToastStyle(PlainToastStyle())
    }
}

public extension EnvironmentValues {
    
    /// The style of Toast components.
    fileprivate(set) var toastStyle: AnyToastStyle {
        get { self[ToastStyleEnvironmentKey.self] }
        set { self[ToastStyleEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    func toastStyle<Style: ToastStyle>(
        _ style: Style
    ) -> some View {
        self.environment(\.toastStyle, AnyToastStyle(style))
    }
}
