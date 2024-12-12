//
//  ToastDismissAction.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// An action that can dismiss a presented toast.
public struct ToastDismissAction: Sendable {
    private let action: @MainActor @Sendable () -> Void
    
    internal init(action: @escaping @MainActor @Sendable () -> Void) {
        self.action = action
    }
    
    @MainActor
    public func callAsFunction() {
        action()
    }
}
