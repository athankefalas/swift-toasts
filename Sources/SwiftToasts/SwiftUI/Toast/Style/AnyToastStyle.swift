//
//  AnyToastStyle.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI
import Combine

public struct AnyToastStyle: ToastStyle {
    private let _makeBody: @MainActor @Sendable (Configuration) -> AnyView
    
    init<Style: ToastStyle>(_ style: Style) {
        self._makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
    
    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}

extension ToastStyle {
    
    func erased() -> AnyToastStyle {
        AnyToastStyle(self)
    }
}
