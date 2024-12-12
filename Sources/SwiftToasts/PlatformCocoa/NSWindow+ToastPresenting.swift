//
//  NSWindow+ToastPresenting.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

#if canImport(Cocoa) && canImport(SwiftUI)
import Cocoa
import SwiftUI

extension NSWindow: ToastPresenting {
    
    private var _toastScheduler: ToastScheduler? {
        get {
            let property = NSAssociatedProperty(\NSWindow._toastScheduler)
            
            if let scheduler = self[property] {
                return scheduler
            }
            
            let scheduler = makeScheduler()
            self[property] = scheduler
            
            return scheduler
        }
    }
    
    var toastScheduler: ToastScheduler {
        _toastScheduler ?? makeScheduler()
    }
    
    private func makeScheduler() -> ToastScheduler {
        return ToastScheduler(presenterID: ObjectIdentifier(self)) { [weak self] toastPresentation in
            await self?.handleToastPresentation(toastPresentation)
        }
    }
    
    private var toastController: NSToastHostingController? {
        get {
            let property = NSAssociatedProperty(\NSWindow.toastController)
            
            if let controller = self[property] {
                return controller
            }
            
            let controller = NSToastHostingController(toastAlignment: .defaultAlignment)
            self[property] = controller
            
            controller.fallbackLoadViewIfNeeded()
            return controller
        }
    }
    
    private func handleToastPresentation(_ toast: ToastPresentation) async {
        let currentPresentationContext = PresentationContext(self)
        
        guard let context = await SwiftToastsConfiguration.current
            .presentationContextSelector
            .selectPresentationContext(in: currentPresentationContext) else {
            
            toast.onPresent?()
            toast.onDismiss?()
            return
        }
        
        present(toast: toast, in: context)
    }
    
    private func present(
        toast: ToastPresentation,
        in context: PresentationContext
    ) {
        guard let toastController else {
            toast.onPresent?()
            toast.onDismiss?()
            return
        }
        
        if let window = context.owner as? NSWindow {
            toastController.present(toast: toast, inWindow: window)
        } else if let viewController = context.owner as? NSViewController {
            toastController.present(toast: toast, inController: viewController)
        } else if let view = context.owner as? NSView {
            toastController.present(toast: toast, inView: view)
        } else {
            toast.onPresent?()
            toast.onDismiss?()
        }
    }
    
    @MainActor
    func prepareForToastPresentationIfNeeded() {
        guard _toastScheduler == nil else {
            return
        }
        
        _ = toastScheduler
        _ = toastController
    }
    
    var titleBarHeight: CGFloat {
        if let contentView = contentView {
            return contentView.frame.height - contentLayoutRect.height
        }
        
        return frame.height - contentRect(forFrameRect: frame).height
    }
}

public extension NSWindow {
    
    var toastPresenter: ToastPresenterProxy {
        self.prepareForToastPresentationIfNeeded()
        return ToastPresenterProxy(toastPresenter: self)
    }
}

#endif
