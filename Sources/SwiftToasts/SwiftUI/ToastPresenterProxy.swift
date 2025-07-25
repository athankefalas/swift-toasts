//
//  ToastPresenterProxy.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// A proxy of a toast presenter that can be used to programmatically schedule toasts.
public struct ToastPresenterProxy: Hashable, @unchecked Sendable, CustomReflectable {
    private weak var toastPresenter: ToastPresenting?
    
    /// A value that indicates whether the toast presenter can currently present toasts.
    public var isPresentationEnabled: Bool {
        toastPresenter != nil
    }
    
    @MainActor
    var presentationSpace: ToastPresentationSpace? {
        toastPresenter?.presentationSpace
    }
    
    public var customMirror: Mirror {
        let toastPresenterID: Any
        
        if let toastPresenter {
            toastPresenterID = "some(\(ObjectIdentifier(toastPresenter).hashValue))"
        } else {
            toastPresenterID = "none"
        }
        
        return Mirror(
            self,
            children: [(label: "toastPresenter", value: toastPresenterID)],
            displayStyle: .struct
        )
    }
    
    internal init() {
        self.init(toastPresenter: nil)
    }
    
    internal init(toastPresenter: ToastPresenting?) {
        self.toastPresenter = toastPresenter
    }
    
    /// Schedules the given `Toast` for presentation.
    /// - Parameters:
    ///   - toast: The Toast to present.
    ///   - toastAlignment: The alignment to use when presenting the Toast.
    ///   - toastStyle: The style to use when presenting the Toast.
    ///   - toastTransition: The transition to use when presenting and dismissing the Toast.
    ///   - presentationCanceller: A controller that can be used to programmatically dismiss a presented Toast.
    ///   - onPresent: A callback invoked when the given Toast is presented.
    ///   - onDismiss: A callback invoked when the given Toast is dismissed.
    @MainActor
    public func schedulePresentation(
        toast: Toast,
        toastAlignment: ToastAlignment,
        toastStyle: AnyToastStyle? = nil,
        toastTransition: ToastTransition? = nil,
        presentationCanceller: ToastPresentationCanceller? = nil,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        schedule(
            presentation: ToastPresentation(
                toast: toast,
                toastAlignment: toastAlignment,
                toastStyle: toastStyle ?? AnyToastStyle(PlainToastStyle()),
                toastTransition: toastTransition ?? .defaultTransition,
                presentationCanceller: presentationCanceller,
                onPresent: onPresent,
                onDismiss: onDismiss
            )
        )
    }
    
    @MainActor
    internal func schedule(
        presentation: ToastPresentation
    ) {
        guard let toastScheduler = toastPresenter?.toastScheduler else {
            return
        }
        
        toastScheduler.schedulePresentation(presentation)
    }
    
    /// Schedules the given `Toast` for presentation.
    /// - Parameters:
    ///   - toast: The Toast to present.
    ///   - toastAlignment: The alignment to use when presenting the Toast.
    ///   - toastStyle: The style to use when presenting the Toast.
    ///   - toastTransition: The transition to use when presenting and dismissing the Toast.
    ///   - presentationCanceller: A controller that can be used to programmatically dismiss a presented Toast.
    ///   - onPresent: A callback invoked when the given Toast is presented.
    ///   - onDismiss: A callback invoked when the given Toast is dismissed.
    /// - Returns: A cancellation token used to cancel the sceduled Toast before it can be presented.
    @MainActor
    public func scheduleCancellablePresentation(
        toast: Toast,
        toastAlignment: ToastAlignment,
        toastStyle: AnyToastStyle? = nil,
        toastTransition: ToastTransition? = nil,
        presentationCanceller: ToastPresentationCanceller? = nil,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) -> AnyCancellable {
        scheduleCancellable(
            presentation: ToastPresentation(
                toast: toast,
                toastAlignment: toastAlignment,
                toastStyle: toastStyle ?? AnyToastStyle(PlainToastStyle()),
                toastTransition: toastTransition ?? .defaultTransition,
                presentationCanceller: presentationCanceller,
                onPresent: onPresent,
                onDismiss: onDismiss
            )
        )
    }
    
    @MainActor
    internal func scheduleCancellable(
        presentation: ToastPresentation
    ) -> AnyCancellable {
        guard let toastScheduler = toastPresenter?.toastScheduler else {
            return AnyCancellable({})
        }
        
        return toastScheduler.scheduleCancellablePresentation(presentation)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toastPresenter != nil)
        
        guard let toastPresenter else {
            return
        }
        
        hasher.combine(ObjectIdentifier(toastPresenter))
    }
    
    public static func == (lhs: ToastPresenterProxy, rhs: ToastPresenterProxy) -> Bool {
        lhs.toastPresenter === rhs.toastPresenter
    }
}

extension ToastPresenterProxy {
    
    @MainActor
    func _schedule(
        presentation: ToastPresentation,
        cancellationPolicy: ToastCancellation,
        cancellables: inout Set<AnyCancellable>
    ) {
        switch cancellationPolicy {
        case .never, .automatic:
            schedule(presentation: presentation)
        case .presentation:
            scheduleCancellable(presentation: presentation)
                .store(in: &cancellables)
        case .always:
            cancellables.forEach({ $0.cancel() })
            cancellables.removeAll()
            scheduleCancellable(presentation: presentation)
                .store(in: &cancellables)
        }
    }
}
