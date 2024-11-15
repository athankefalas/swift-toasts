//
//  NSToastHostingController.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

#if canImport(Cocoa) && canImport(SwiftUI)
import Cocoa
import SwiftUI
import Combine

final class NSToastHostingController: NSViewController {
    
    final class NSPassthroughBackdropView: NSView {
        
        final override func hitTest(_ point: NSPoint) -> NSView? {
            let target = super.hitTest(point)
            
            guard let target = target,
                  target === self,
                  let subview = subviews.first else {
                return target
            }
            
            return subview
        }
    }
    
    private var _toastAlignment: ToastAlignment = .defaultAlignment
    private let hostingController = NSHostingController(rootView: HostedToastContent())
    private var hostingControllerConstraints: [NSLayoutConstraint] = []
    private var presentationTask: Task<Void, Never>?
    private weak var toastWindow: NSTransientFloatingWindow?
    
    private(set) var toastAlignment: ToastAlignment {
        get { _toastAlignment }
        set {
            guard _toastAlignment != newValue else {
                return
            }
            
            _toastAlignment = newValue
            fallbackLoadViewIfNeeded()
            makeLayoutConstraints()
        }
    }
    
    convenience init(toastAlignment: ToastAlignment) {
        self.init(nibName: nil, bundle: nil)
        self._toastAlignment = toastAlignment
    }
    
    override var acceptsFirstResponder: Bool {
        hostingController.acceptsFirstResponder
    }
    
    override func loadView() {
        super.loadView()
        
        let view = NSPassthroughBackdropView()
        view.wantsLayer = true
        view.autoresizingMask = self.view.autoresizingMask
        view.layer?.backgroundColor = .clear
        self.view = view
        
        addChild(hostingController)
        view.addSubview(hostingController.view, positioned: .above, relativeTo: nil)
        hostingController.view.wantsLayer = true
        hostingController.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        hostingController.view.layer?.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        makeLayoutConstraints()
    }
    
    private final func makeLayoutConstraints() {
        let hostedView = hostingController.view
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
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
                
        guard let window = toastWindow?.presentingWindow else {
            return
        }
        
        if #available(macOS 11.0, *) {
            view.additionalSafeAreaInsets = NSEdgeInsets(
                top: window.titleBarHeight,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
    
    final func present(
        toast toastPresentation: ToastPresentation,
        inWindow parent: NSWindow
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
    
    private final func attachToParent(
        _ parent: NSWindow,
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
    
    private final func attach(to parent: NSWindow) {
        let toastWindow = NSTransientFloatingWindow(
            contentViewController: self,
            floatingIn: parent
        )
        
        self.toastWindow = toastWindow
        self.toastWindow?.show()
    }
    
    final func present(
        toast toastPresentation: ToastPresentation,
        inView parent: NSView
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
    
    private final func attachToParent(
        _ parent: NSView,
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
    
    private final func attach(to parent: NSView) {
        parent.addSubview(self.view)
        view.frame = parent.bounds
    }
    
    final func present(
        toast toastPresentation: ToastPresentation,
        inController parent: NSViewController
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
    
    private final func attachToParent(
        _ parent: NSViewController,
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
    
    private final func attach(to parent: NSViewController) {
        parent.addChild(self)
        parent.view.addSubview(self.view)
        view.frame = parent.view.bounds
    }
    
    private final func makeHandlingTask(
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
    
    private final func dismissToast() {
        presentationTask?.cancel()
    }
    
    private final func detachFromParent(
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
    
    private final func detach() {
        toastWindow?.hide()
        view.removeFromSuperview()
        removeFromParent()
        toastWindow = nil
    }
    
    private final func layoutAndReset() {
        hostingController.view.resetPresentationAnimationProperties()
        view.layout()
        hostingController.view.layout()
    }
    
    private final func makeAnimationContext(
        phase: ToastTransition.PresentationPhase,
        toast: ToastPresentation
    ) -> ToastTransition.Context {
        return ToastTransition.Context(
            phase: phase,
            geometry: makeGeometryInfo(),
            windowGeometry: view.window?.frame ?? .zero,
            platformIdiom: .current,
            isReduceMotionEnabled: NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
            isReduceTransparencyEnabled: NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency,
            presentation: toast
        )
    }
    
    private final func makeGeometryInfo() -> CGRect {
        let view = hostingController.view
        view.layout()
        view.superview?.layoutSubtreeIfNeeded()
        
        var frame = view.convert(view.frame, to: nil)
        frame.size.width = max(frame.size.width, view.intrinsicContentSize.width)
        frame.size.height = max(frame.size.height, view.intrinsicContentSize.height)
        
        return view.isFlipped ? frame : flip(frame: frame, of: view)
    }
    
    private final func flip(
        frame: CGRect,
        of view: NSView
    ) -> CGRect {
        var frame = frame
        
        guard let window = view.window else {
            return frame
        }
        
        let windowHeight = window.frame.height
        frame.origin.y = windowHeight - frame.origin.y
        
        return frame
    }
}

#endif
