//
//  ToastStyleEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//


import SwiftUI
import Combine

private struct ToastStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyToastStyle {
        MainActor.assumeIsolated {
            AnyToastStyle(PlainToastStyle())
        }
    }
}

public extension EnvironmentValues {
    
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
