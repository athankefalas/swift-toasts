//
//  ToastIdentifiableTaskModifier.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 11/10/24.
//

import SwiftUI

private struct ToastIdentifiableTaskModifier<ID: Equatable>: ViewModifier {
    
    @Environment(\.toastPresenter)
    private var toastPresenter
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    @Environment(\.toastTransition)
    private var toastTransition
    
    @Environment(\.toastCancellation)
    private var toastCancellation
    
    @PresentationBoundState
    private var cancellablesBox = CancellablesBox()
    
    private let identity: ID
    private let priority: TaskPriority
    private let operation: @MainActor (ScheduleToastAction) async -> Void
    
    init(
        identity: ID,
        priority: TaskPriority,
        operation: @escaping @MainActor (ScheduleToastAction) async -> Void
    ) {
        self.identity = identity
        self.priority = priority
        self.operation = operation
    }
    
    func body(content: Content) -> some View {
        content.fallbackTask(id: identity, priority: priority) {
            await operation(
                ScheduleToastAction(
                    toastPresenterProxy: toastPresenter,
                    toastStyle: toastStyle,
                    toastTransition: toastTransition,
                    toastCancellation: toastCancellation,
                    preferredCancellation: .presentation,
                    cancellablesBox: cancellablesBox
                )
            )
        }
    }
}

public extension View {
    
    func task<ID: Equatable>(
        id: ID,
        priority: TaskPriority = .userInitiated,
        operation: @escaping @MainActor (ScheduleToastAction) async -> Void
    ) -> some View {
        modifier(
            ToastIdentifiableTaskModifier(
                identity: id,
                priority: priority,
                operation: operation
            )
        )
    }
}
