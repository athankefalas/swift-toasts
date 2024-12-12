//
//  ToastPresentation.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import Foundation

@MainActor
struct ToastPresentation: Sendable {
    private(set) var toast: Toast
    private(set) var toastAlignment: ToastAlignment
    private(set) var toastStyle: AnyToastStyle
    private(set) var toastTransition: ToastTransition
    private(set) var presentationCanceller: ToastPresentationCanceller?
    private(set) var onPresent: (@MainActor () -> Void)?
    private(set) var onDismiss: (@MainActor () -> Void)?
    
    init(
        toast: Toast,
        toastAlignment: ToastAlignment,
        toastStyle: AnyToastStyle = AnyToastStyle(PlainToastStyle()),
        toastTransition: ToastTransition = .defaultTransition,
        presentationCanceller: ToastPresentationCanceller?,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self.toast = toast
        self.toastAlignment = toastAlignment
        self.toastStyle = toastStyle
        self.toastTransition = toastTransition
        self.presentationCanceller = presentationCanceller
        self.onPresent = onPresent
        self.onDismiss = onDismiss
    }
    
    func onPresent(
        perform presentationAction: @escaping @MainActor () -> Void
    ) -> ToastPresentation {
        let onPresent = self.onPresent
        let compositeOnPresent: @MainActor () -> Void = {
            onPresent?()
            presentationAction()
        }
        
        var mutableCopy = self
        mutableCopy.onPresent = compositeOnPresent
        
        return mutableCopy
    }
    
    func onDismiss(
        perform dismissalAction: @escaping @MainActor () -> Void
    ) -> ToastPresentation {
        let onDismiss = self.onDismiss
        let compositeOnDismiss: @MainActor () -> Void = {
            onDismiss?()
            dismissalAction()
        }
        
        var mutableCopy = self
        mutableCopy.onDismiss = compositeOnDismiss
        
        return mutableCopy
    }
}
