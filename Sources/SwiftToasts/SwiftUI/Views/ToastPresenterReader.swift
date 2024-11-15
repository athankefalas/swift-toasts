//
//  ToastPresenterReader.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

/// A container view that reads the toast presenter in it's View hierarchy and provides it to it's content.
///
/// This view returns a preferred size to its parent layout that hugs it's `Content`.
///
/// In platforms that support a single window only `ToastPresenterReader` will essentially read the
/// same toast presenter as the one found in the environment, and it might be better to directly use
/// the `toastPresenter` environment value to read the toast presenter value.
///
/// However, in platforms that multiple windows are supported, `ToastPresenterReader` will attempt to read the toast presenter bound to it's parent window, and can be used to present toasts in diferrent windows.
public struct ToastPresenterReader<Content: View>: View {
    
    @Environment(\.toastPresenter)
    private var outterToastPresenter
    
    @State
    private var assignedPresenter = false
    
    @State
    private var toastPresenter = ToastPresenterProxy()
    
    private let content: (ToastPresenterProxy) -> Content
    
    public init(
        @ViewBuilder content: @escaping (ToastPresenterProxy) -> Content
    ) {
        self.content = content
    }
    
    private var innerToastPresenter: ToastPresenterProxy {
        guard outterToastPresenter.presentationSpace != .explicitLayout else {
            return outterToastPresenter
        }
        
        return toastPresenter
    }
    
    public var body: some View {
        ZStack {
            if innerToastPresenter.isPresentationEnabled || assignedPresenter {
                content(innerToastPresenter)
            }
        }
        .assignToastPresenter(to: $toastPresenter)
        .fallbackOnChange(of: toastPresenter) { newValue in
            assignedPresenter = true
        }
        .fallbackTask {
            await Task.yield()
            
            guard !assignedPresenter else {
                return
            }
            
            assignedPresenter = true
        }
    }
}

// MARK: Previews

#if DEBUG

#Preview {
    ToastPresenterReader { proxy in
        let transitionUnderTest = ToastTransition.scale
            .combined(with: .opacity)
        
        Button(proxy.isPresentationEnabled ? "Found" : "Not Found") {
            proxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top,
                toastTransition: transitionUnderTest
            )
        }
        .onAppear {
            proxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top,
                toastTransition: transitionUnderTest
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(watchOS)
    .toastPresentingLayout()
#endif
}

#endif
