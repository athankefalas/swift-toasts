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
/// that provided them and therefore, it is recommended that they are not retained outside of their scope.
public struct ScheduleToastAction: CustomReflectable {
    public let toastPresenterProxy: ToastPresenterProxy
    
    private let toastStyle: AnyToastStyle
    private let toastTransition: ToastTransition
    private let toastCancellation: ToastCancellation
    private let preferredCancellation: ToastCancellation
    private weak var cancellablesBox: CancellablesBox?
    
    /// A value that indicates whether the toast presenter can currently present toasts.
    public var isPresentationEnabled: Bool {
        toastPresenterProxy.isPresentationEnabled
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
        toastStyle: AnyToastStyle,
        toastTransition: ToastTransition,
        toastCancellation: ToastCancellation,
        preferredCancellation: ToastCancellation,
        cancellablesBox: CancellablesBox
    ) {
        self.toastPresenterProxy = toastPresenterProxy
        self.toastStyle = toastStyle
        self.toastTransition = toastTransition
        self.toastCancellation = toastCancellation
        self.preferredCancellation = preferredCancellation
        self.cancellablesBox = cancellablesBox
        assert(preferredCancellation != .automatic)
    }
    
    @MainActor
    public func schedule(
        toast: Toast,
        alignment toastAlignment: ToastAlignment = .defaultAlignment,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        
        if cancellablesBox == nil && toastCancellation != .never {
#if DEBUG
            print("WARNING: An instance of 'ScheduleToastAction' was leaked.")
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
                toastStyle: toastStyle,
                toastTransition: toastTransition,
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
