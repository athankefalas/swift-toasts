//
//  UIWindowToastPresenterReaderModifier.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
import UIKit
import SwiftUI

private struct UIWindowToastPresenterReaderModifier: ViewModifier {
    
    struct WindowReader: UIViewRepresentable {
        
        final class View: UIView {
            private var reader: ((UIWindow?) -> Void)?
            
            convenience init(reader: @escaping (UIWindow?) -> Void) {
                self.init(frame: .zero)
                self.backgroundColor = .clear
                self.reader = reader
            }
            
            override func didMoveToWindow() {
                super.didMoveToWindow()
                reader?(window)
            }
            
            final func update(reader: @escaping (UIWindow?) -> Void) {
                self.reader = reader
                reader(window)
            }
        }
        
        private var reader: (UIWindow?) -> Void
        
        init(reader: @escaping (UIWindow?) -> Void) {
            self.reader = reader
        }
        
        func makeUIView(context: Context) -> View {
            View(reader: reader)
        }
        
        func updateUIView(_ uiView: View, context: Context) {
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
    
    func assignUIWindowToastPresenter(
        to binding: Binding<ToastPresenterProxy>
    ) -> some View {
        modifier(
            UIWindowToastPresenterReaderModifier(
                toastPresenter: binding
            )
        )
    }
}

@MainActor
internal func _getDefaultUIWindowToastPresenter() -> ToastPresenting? {
    return UIApplication.shared
        .connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .compactMap({ $0.fallbackKeyWindow })
        .first
}

#endif
