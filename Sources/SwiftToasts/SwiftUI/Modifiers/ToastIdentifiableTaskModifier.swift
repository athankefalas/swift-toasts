//
//  ToastIdentifiableTaskModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 11/10/24.
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
    
    @Environment(\.toastInteractiveDismissEnabled)
    private var toastInteractiveDismissEnabled
    
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
                    toastEnvironmentValues: ToastEnvironmentValues(
                        toastStyle: toastStyle,
                        toastTransition: toastTransition,
                        toastInteractiveDismissEnabled: toastInteractiveDismissEnabled
                    ),
                    toastCancellation: toastCancellation,
                    preferredCancellation: .presentation,
                    cancellablesBox: cancellablesBox
                )
            )
        }
    }
}

public extension View {
    
    /// Adds an asynchronous task to perform before this view appears or when the specified value changes and optionally use the given `ScheduleToastAction` to present a Toast.
    /// - Parameters:
    ///   - id: A value that defines the identity of the attached Task.
    ///   - priority: The priority of the attached Task.
    ///   - operation: The async operation performed by the attached Task.
    /// - Note: The given schedule action may outlive the owning View, in which case the scheduled Toast may never be presented.
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
