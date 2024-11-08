//
//  UIWindow+ToastPresenting .swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
import UIKit
import SwiftUI

extension UIWindow: ToastPresenting {
    
    private var _toastScheduler: ToastScheduler? {
        get {
            let property = NSAssociatedProperty(\UIWindow._toastScheduler)
            
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
    
    private var toastController: UIToastHostingController? {
        get {
            let property = NSAssociatedProperty(\UIWindow.toastController)
            
            if let controller = self[property] {
                return controller
            }
            
            let controller = UIToastHostingController(toastAlignment: .defaultAlignment)
            self[property] = controller
            
            controller.loadViewIfNeeded()
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
        
        if let window = context.owner as? UIWindow {
            toastController.present(toast: toast, inView: window)
        } else if let viewController = context.owner as? UIViewController {
            toastController.present(toast: toast, inController: viewController)
        } else if let view = context.owner as? UIView {
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
}

public extension UIWindow {
    
    var toastPresenter: ToastPresenterProxy {
        self.prepareForToastPresentationIfNeeded()
        return ToastPresenterProxy(toastPresenter: self)
    }
}

#endif
