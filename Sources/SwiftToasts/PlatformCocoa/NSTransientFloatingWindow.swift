//
//  NSTransientFloatingWindow.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 24/10/24.
//

#if canImport(Cocoa)
import Cocoa
import Combine

final class NSTransientFloatingWindow: NSPanel {
    private(set) weak var presentingWindow: NSWindow?
    private var subscriptions: Set<AnyCancellable> = []
    
    private(set) var isShown = false
    
    override var canBecomeMain: Bool {
        false
    }
    
    override var canBecomeKey: Bool {
        false
    }
    
    override var isKeyWindow: Bool {
        get {
            if isShown {
                return true
            }
            
            return super.isKeyWindow
        }
    }
    
    convenience init(
        contentViewController: NSViewController,
        floatingIn parent: NSWindow
    ) {
        self.init(contentViewController: contentViewController)
        presentingWindow = parent
        postInit(parent: parent)
    }
    
    deinit {
        MainActor.assumeIsolated {
            subscriptions.forEach({ $0.cancel() })
            subscriptions.removeAll()
        }
    }
    
    private final func postInit(parent: NSWindow) {
        self.level = .floating
        self.isFloatingPanel = true
        self.styleMask = [.borderless, .nonactivatingPanel, .hudWindow]
        self.isExcludedFromWindowsMenu = true
        self.becomesKeyOnlyIfNeeded = true
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = .clear
        self.backingType = parent.backingType
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.backgroundColor = .clear
        self.setContentSize(parent.frame.size)
        self.setFrameOrigin(parent.frame.origin)
        
        if #available(macOS 13.0, *) {
            self.collectionBehavior = [.ignoresCycle, .auxiliary, .stationary, .transient, .fullScreenAuxiliary]
        } else {  // Fallback on earlier versions
            self.collectionBehavior = [.ignoresCycle, .stationary, .transient, .fullScreenAuxiliary]
        }
        
        if #available(macOS 11.0, *) {
            parent.contentView?
                .publisher(for: \.safeAreaInsets)
                .sink { [weak self] _ in
                    guard self?.isShown == true else {
                        return
                    }
                    
                    self?.contentView?.needsLayout = true
                }
                .store(in: &subscriptions)
        }
        
        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeKeyNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak parent, weak self] window in
                guard window === parent, self?.isShown == true else {
                    return
                }
                
                self?.orderFrontRegardless()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak parent, weak self] window in
                
                guard window === parent, self?.isShown == true else {
                    return
                }
                
                self?.setContentSize(window.frame.size)
                self?.setFrameOrigin(window.frame.origin)
                self?.contentView?.needsLayout = true
                self?.orderFrontRegardless()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak parent, weak self] window in
                
                guard window === parent, self?.isShown == true else {
                    return
                }
                
                self?.hide()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSApplication.willHideNotification)
            .sink { [weak self] _ in
                
                guard self?.isShown == true else {
                    return
                }
                
                self?.hide()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                guard self?.isShown == true else {
                    return
                }
                
                self?.hide()
            }
            .store(in: &subscriptions)
    }
    
    final func show() {
        guard let parent = presentingWindow,
              !isShown else {
            return
        }
        
        self.isShown = true
        let presentingParentWindow = parent.attachedSheet ?? parent
        presentingParentWindow.addChildWindow(self, ordered: .above)
        
        
//        self.becomeKey() // Workaround for visual effects that appear dimmed.
//        NotificationCenter.default.post(name: NSWindow.didBecomeKeyNotification, object: self)
        self.orderFrontRegardless()
        self.contentView?.needsLayout = true
        
//        NSApplication.shared.windows
//            .filter({ $0.isKeyWindow })
//            .forEach { window in
//                print("## Class: \(type(of: window))")
//            }
//        
//        guard let keyWindow = NSApp.keyWindow else {
//            return
//        }
//        print("## Real key window: \(type(of: keyWindow)) - \(keyWindow)")
    }
    
    final func hide() {
        guard isShown else {
            return
        }
        
        self.isShown = false
        parent?.removeChildWindow(self)
        self.orderOut(nil)
    }
}

#endif
