//
//  ToastDismissAction.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// An action that can dismiss a presented toast.
public struct ToastDismissAction: Hashable, Sendable {
    private let idSignature: Int
    private let action: @MainActor @Sendable () -> Void
    
    internal init(
        id: AnyHashable,
        action: @escaping @MainActor @Sendable () -> Void
    ) {
        self.idSignature = id.hashValue
        self.action = action
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(idSignature)
    }
    
    @MainActor
    public func callAsFunction() {
        action()
    }
    
    public static func == (lhs: ToastDismissAction, rhs: ToastDismissAction) -> Bool {
        lhs.idSignature == rhs.idSignature
    }
}
