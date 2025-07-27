//
//  ToastPresentationProxy.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 10/10/24.
//

import SwiftUI
import Combine

/// A high level proxy for scehduling toast presentations that is preconfigured with values from the environment of a view hierarchy.
/// An instance of `ScheduleToastAction` can be used to present a toast, however if more customization
/// is required, it may be preferred to use an instance of `ToastPresenterProxy` instead.
///
/// - Warning: Instances of `ScheduleToastAction` are directly tied to the lifetime of the view
/// that provided them and therefore, it is recommended that they are not retained outside of their scope. If a `Toast`
/// is scheduled using an instance of `ScheduleToastAction` that has outlived it's owner's lifetime the presentation
/// may have no effect at all.
public struct ScheduleToastAction: CustomReflectable {
    public let toastPresenterProxy: ToastPresenterProxy
    
    private let toastEnvironmentValues: ToastEnvironmentValues
    private let toastCancellation: ToastCancellation
    private let preferredCancellation: ToastCancellation
    private weak var cancellablesBox: CancellablesBox?
    
    /// A value that indicates whether the toast presenter can currently present toasts.
    public var isPresentationEnabled: Bool {
        if cancellablesBox == nil && toastCancellation != .never {
            return false
        }
        
        return toastPresenterProxy.isPresentationEnabled
    }
    
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [(label: "toastPresenterProxy", value: toastPresenterProxy)],
            displayStyle: .struct
        )
    }
    
    init(
        toastPresenterProxy: ToastPresenterProxy,
        toastEnvironmentValues: ToastEnvironmentValues = ToastEnvironmentValues(),
        toastCancellation: ToastCancellation,
        preferredCancellation: ToastCancellation,
        cancellablesBox: CancellablesBox
    ) {
        self.toastPresenterProxy = toastPresenterProxy
        self.toastEnvironmentValues = toastEnvironmentValues
        self.toastCancellation = toastCancellation
        self.preferredCancellation = preferredCancellation
        self.cancellablesBox = cancellablesBox
        assert(preferredCancellation != .automatic)
    }
    
    /// Schedules the given `Toast` for presentation.
    /// - Parameters:
    ///   - toast: The Toast to present.
    ///   - toastAlignment: The alignment to use when presenting the Toast.
    ///   - onPresent: A callback invoked when the given Toast is presented.
    ///   - onDismiss: A callback invoked when the given Toast is dismissed.
    @MainActor
    public func schedule(
        toast: Toast,
        alignment toastAlignment: ToastAlignment = .defaultAlignment,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        
        if cancellablesBox == nil && toastCancellation != .never {
#if DEBUG
            runtimeWarn(
                "An instance of 'ScheduleToastAction' was leaked, the Toast will NOT be presented. Please consider checking `isPresentationEnabled` before calling `schedule`.",
                file: file,
                function: function,
                line: line
            )
#endif
            return
        }
        
        var cancellables = cancellablesBox?.cancellables ?? []
        defer {
            cancellablesBox?.cancellables = cancellables
        }
        
        toastPresenterProxy._schedule(
            presentation: ToastPresentation(
                toast: toast,
                toastAlignment: toastAlignment,
                toastEnvironmentValues: toastEnvironmentValues,
                presentationCanceller: nil,
                onPresent: onPresent,
                onDismiss: onDismiss
            ),
            cancellationPolicy: toastCancellation.byReplacingAutomatic(
                with: preferredCancellation
            ),
            cancellables: &cancellables
        )
    }
    
    @MainActor
    func callAsFunction(
        toast: Toast,
        alignment toastAlignment: ToastAlignment = .defaultAlignment,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self.schedule(
            toast: toast,
            alignment: toastAlignment,
            onPresent: onPresent,
            onDismiss: onDismiss
        )
    }
}
