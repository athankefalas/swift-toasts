//
//  ToastTaskModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 11/10/24.
//

import SwiftUI

private struct ToastTaskModifier: ViewModifier {
    
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
    
    private let priority: TaskPriority
    private let operation: @MainActor (ScheduleToastAction) async -> Void
    
    init(
        priority: TaskPriority,
        operation: @escaping @MainActor (ScheduleToastAction) async -> Void
    ) {
        self.priority = priority
        self.operation = operation
    }
    
    func body(content: Content) -> some View {
        content.fallbackTask(priority: priority) {
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
    
    /// Adds an asynchronous task to perform before this view appears and optionally use the given `ScheduleToastAction` to present a Toast.
    /// - Parameters:
    ///   - priority: The priority of the attached Task.
    ///   - operation: The async operation performed by the attached Task.
    /// - Note: The given schedule action may outlive the owning View, in which case the scheduled Toast may never be presented.
    func task(
        priority: TaskPriority = .userInitiated,
        operation: @escaping @MainActor (ScheduleToastAction) async -> Void
    ) -> some View {
        modifier(
            ToastTaskModifier(
                priority: priority,
                operation: operation
            )
        )
    }
}
