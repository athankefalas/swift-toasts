//
//  ToastConfiguration.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// The properties of a Toast component.
@MainActor
public struct ToastConfiguration: Sendable {
    public let role: ToastRole
    public let duration: ToastDuration
    public let content: AnyView
    
    init<Content: View>(
        role: ToastRole,
        duration: ToastDuration,
        content: Content
    ) {
        self.role = role
        self.duration = duration
        self.content = AnyView(content)
    }
}
