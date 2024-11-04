//
//  NSTransientFloatingWindow.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/10/24.
//

#if canImport(Cocoa)
import Cocoa
import Combine

final class NSTransientFloatingWindow: NSWindow {
    private(set) weak var presentingWindow: NSWindow?
    private var subscriptions: Set<AnyCancellable> = []
    
    private(set) var isShown = false
    
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
    
    private func postInit(parent: NSWindow) {
        self.level = .floating
        self.styleMask = .hudWindow
        self.isExcludedFromWindowsMenu = true
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
            .sink { [weak self] _ in
                
                guard self?.isShown == true else {
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
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak parent, weak self] window in
                
                guard window === parent, self?.isShown == true else {
                    return
                }
                
                self?.hide()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSApplication.willResignActiveNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak parent, weak self] window in
                
                guard window === parent, self?.isShown == true else {
                    return
                }
                
                self?.hide()
            }
            .store(in: &subscriptions)
    }
    
    func show() {
        guard let parent = presentingWindow,
              !isShown else {
            return
        }
        
        let presentingParentWindow = parent.attachedSheet ?? parent
        presentingParentWindow.addChildWindow(self, ordered: .above)
        
        self.isShown = true
        self.orderFrontRegardless()
        self.contentView?.needsLayout = true
    }
    
    func hide() {
        guard isShown else {
            return
        }
        
        parent?.removeChildWindow(self)
        self.isShown = false
    }
}

#endif
