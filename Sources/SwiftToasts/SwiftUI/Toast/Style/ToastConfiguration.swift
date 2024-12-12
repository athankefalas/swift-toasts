//
//  ToastConfiguration.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

@MainActor
public struct ToastConfiguration: Sendable {
    private(set) var role: ToastRole
    private(set) var duration: ToastDuration
    private(set) var content: AnyView
    
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
