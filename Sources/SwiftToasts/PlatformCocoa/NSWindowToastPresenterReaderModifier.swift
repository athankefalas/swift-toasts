//
//  NSWindowToastPresenterReaderModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

#if canImport(Cocoa) && canImport(SwiftUI)
import Cocoa
import SwiftUI

private struct NSWindowToastPresenterReaderModifier: ViewModifier {
    
    struct WindowReader: NSViewRepresentable {
        
        final class View: NSView {
            private var reader: ((NSWindow?) -> Void)?
            
            convenience init(reader: @escaping (NSWindow?) -> Void) {
                self.init(frame: .zero)
                self.reader = reader
            }
            
            override func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()
                reader?(window)
            }
            
            final func update(reader: @escaping (NSWindow?) -> Void) {
                self.reader = reader
                reader(window)
            }
        }
        
        private var reader: (NSWindow?) -> Void
        
        init(reader: @escaping (NSWindow?) -> Void) {
            self.reader = reader
        }
        
        func makeNSView(context: Context) -> View {
            View(reader: reader)
        }
        
        func updateNSView(_ uiView: View, context: Context) {
            uiView.update(reader: reader)
        }
    }
    
    @Binding
    var toastPresenter: ToastPresenterProxy
    
    func body(content: Content) -> some View {
        content.background(
            WindowReader { window in
                let newValue = ToastPresenterProxy(toastPresenter: window)
                
                guard newValue != toastPresenter else {
                    return
                }
                
                toastPresenter = newValue
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            .fallbackAccessibilityHidden(true)
        )
    }
}

extension View {
    
    func assignNSWindowToastPresenter(
        to binding: Binding<ToastPresenterProxy>
    ) -> some View {
        modifier(
            NSWindowToastPresenterReaderModifier(
                toastPresenter: binding
            )
        )
    }
}

@MainActor
internal func _getDefaultNSWindowToastPresenter() -> ToastPresenting? {
    return NSApplication.shared
        .windows
        .filter({ $0.level == .normal && ($0.isMainWindow || $0.canBecomeMain) && $0.isVisible })
        .last
}

#endif
