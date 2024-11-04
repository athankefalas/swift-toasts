//
//  UIToastHostingController.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

#if canImport(UIKit) && canImport(SwiftUI) && canImport(Combine) && !os(watchOS)
import UIKit
import SwiftUI
import Combine

class UIToastHostingController: UIViewController {
    
    private class UIPassthroughBackdropView: UIView {
        weak var hostingView: UIView?
        
        private var hostedContentFrame: CGRect {
            
            guard let hostingView else {
                return .zero
            }
            
            var frame = CGRect.zero
            
            for subview in hostingView.subviews {
                frame = frame.union(subview.frame)
            }
            
            return frame
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let target = super.hitTest(point, with: event)
            
            guard let hostingView = hostingView else {
                return target
            }
            
            let convertedPoint = convert(point, to: hostingView)
            let containsPoint = hostedContentFrame.contains(convertedPoint)
            
            guard target !== self, containsPoint else {
                return nil
            }
            
            return target
        }
    }
    
    private var _toastAlignment: ToastAlignment = .defaultAlignment
    private let hostingController = UIHostingController(rootView: HostedToastContent())
    private var hostingControllerConstraints: [NSLayoutConstraint] = []
    private var presentationTask: Task<Void, Never>?
    
    private(set) var toastAlignment: ToastAlignment {
        get { _toastAlignment }
        set {
            guard _toastAlignment != newValue else {
                return
            }
            
            _toastAlignment = newValue
            loadViewIfNeeded()
            makeLayoutConstraints()
        }
    }
    
    convenience init(toastAlignment: ToastAlignment) {
        self.init(nibName: nil, bundle: nil)
        self._toastAlignment = toastAlignment
    }
    
    override func loadView() {
        super.loadView()
        
        let backdropView = UIPassthroughBackdropView()
        backdropView.backgroundColor = .clear
        backdropView.autoresizingMask = view.autoresizingMask
        backdropView.frame = view.frame
        backdropView.hostingView = hostingController.view
        view = backdropView
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        makeLayoutConstraints()
        
        hostingController.didMove(toParent: self)
    }
    
    private func makeLayoutConstraints() {
        let hostedView = hostingController.view!
        view.removeConstraints(hostingControllerConstraints)
        hostedView.removeConstraints(hostingControllerConstraints)
        hostingControllerConstraints = PlatformLayoutConstraints.placing(
            view: hostedView,
            inside: view,
            alignment: toastAlignment
        )
        
        NSLayoutConstraint.activate(hostingControllerConstraints)
    }
    
    deinit {
        MainActor.assumeIsolated {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }
    }
    
    func present(
        toast toastPresentation: ToastPresentation,
        inView parent: UIView
    ) {
        presentationTask?.cancel()
        toastPresentation.onPresent?()
        toastAlignment = toastPresentation.toastAlignment
        hostingController.rootView = HostedToastContent(
            hosting: toastPresentation
        ) { [weak self] in
            self?.dismissToast()
        }
        
        attachToParent(parent, toastPresentation: toastPresentation) {
            self.presentationTask = self.makeHandlingTask(toastPresentation: toastPresentation)
        }
    }
    
    private func attachToParent(
        _ parent: UIView,
        toastPresentation: ToastPresentation,
        completion: @escaping () -> Void
    ) {
        attach(to: parent)
        layoutAndReset()
        
        hostingController.view.animate(
            transition: toastPresentation.toastTransition,
            in: makeAnimationContext(
                phase: .toastInsertion,
                toast: toastPresentation
            )
        ) { isFinished in
            self.layoutAndReset()
            completion()
        }
    }
    
    private func attach(to parent: UIView) {
        parent.addSubview(self.view)
        view.frame = parent.bounds
    }
    
    func present(
        toast toastPresentation: ToastPresentation,
        inController parent: UIViewController
    ) {
        presentationTask?.cancel()
        toastPresentation.onPresent?()
        toastAlignment = toastPresentation.toastAlignment
        hostingController.rootView = HostedToastContent(
            hosting: toastPresentation
        ) { [weak self] in
            self?.dismissToast()
        }
        
        attachToParent(parent, toastPresentation: toastPresentation) {
            self.presentationTask = self.makeHandlingTask(toastPresentation: toastPresentation)
        }
    }
    
    private func attachToParent(
        _ parent: UIViewController,
        toastPresentation: ToastPresentation,
        completion: @escaping () -> Void
    ) {
        attach(to: parent)
        layoutAndReset()
        
        hostingController.view.animate(
            transition: toastPresentation.toastTransition,
            in: makeAnimationContext(
                phase: .toastInsertion,
                toast: toastPresentation
            )
        ) { isFinished in
            self.layoutAndReset()
            completion()
        }
    }
    
    private func attach(to parent: UIViewController) {
        parent.addChild(self)
        parent.view.addSubview(self.view)
        view.frame = parent.view.bounds
        didMove(toParent: parent)
    }
    
    private func makeHandlingTask(
        toastPresentation: ToastPresentation
    ) -> Task<Void, Never> {
        return Task {
            defer {
                presentationTask = nil
            }
            
            try? await Task.sleep(duration: toastPresentation.toast.configuration.duration)
            detachFromParent(toastPresentation: toastPresentation) {
                toastPresentation.onDismiss?()
            }
        }
    }
    
    private func dismissToast() {
        presentationTask?.cancel()
    }
    
    private func detachFromParent(
        toastPresentation: ToastPresentation,
        completion: @escaping () -> Void
    ) {
        layoutAndReset()
        hostingController.view.animate(
            transition: toastPresentation.toastTransition,
            in: makeAnimationContext(
                phase: .toastRemoval,
                toast: toastPresentation
            )
        ) { isFinished in
            self.detach()
            self.layoutAndReset()
            completion()
        }
    }
    
    private func detach() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    private func layoutAndReset() {
        hostingController.view.resetPresentationAnimationProperties()
        view.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
    }
    
    private func makeAnimationContext(
        phase: ToastTransition.PresentationPhase,
        toast: ToastPresentation
    ) -> ToastTransition.Context {
        return ToastTransition.Context(
            phase: phase,
            geometry: makeGeometryInfo(),
            windowGeometry: view.window?.frame ?? .zero,
            platformIdiom: .current,
            isReduceMotionEnabled: UIAccessibility.isReduceMotionEnabled,
            isReduceTransparencyEnabled: UIAccessibility.isReduceTransparencyEnabled,
            presentation: toast
        )
    }
    
    private func makeGeometryInfo() -> CGRect {
        hostingController.view.convert(hostingController.view.frame, to: nil)
    }
}

#endif

