//
//  AnyToastContentStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI

/// A type erased `ToastContentStyle`.
public struct AnyToastContentStyle: ToastContentStyle {
    private let _makeBody: @MainActor @Sendable (Configuration) -> AnyView
    
    nonisolated public init<Style: ToastContentStyle>(_ style: Style) {
        self._makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
    
    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}

extension ToastContentStyle {
    
    nonisolated func erased() -> AnyToastContentStyle {
        AnyToastContentStyle(self)
    }
}
