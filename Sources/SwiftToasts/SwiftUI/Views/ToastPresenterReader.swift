//
//  ToastPresenterReader.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

/// A container view that reads the toast presenter in it's View hierarchy and provides it to it's content.
public struct ToastPresenterReader<Content: View>: View {
    
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
    
    public var body: some View {
        ZStack {
            if toastPresenter.isPresentationEnabled || assignedPresenter {
                content(toastPresenter)
            }
        }
        .assignToastPresenter(to: $toastPresenter)
        .fallbackOnChange(of: toastPresenter) { newValue in
            assignedPresenter = true
        }
    }
}

// MARK: Previews

#if DEBUG

#Preview {
    ToastPresenterReader { proxy in
        Button(proxy.isPresentationEnabled ? "Found" : "Not Found") {
            proxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top
            )
        }
        .onAppear {
            proxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top
            )
        }
    }
}

#endif
