//
//  AnyToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// A type erased `ToastStyle`.
public struct AnyToastStyle: ToastStyle {
    private let _makeBody: @MainActor @Sendable (Configuration) -> AnyView
    
    nonisolated public init<Style: ToastStyle>(_ style: Style) {
        self._makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
    
    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}

extension ToastStyle {
    
    nonisolated func erased() -> AnyToastStyle {
        AnyToastStyle(self)
    }
}
