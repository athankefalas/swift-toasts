//
//  ToastPresenterReader.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// A container view that reads the toast presenter in it's View hierarchy and provides it to it's content.
///
/// This view returns a preferred size to its parent layout that hugs it's `Content`.
public struct ToastPresenterReader<Content: View>: View {
    
    @Environment(\.toastPresenter)
    private var toastPresenter
    
    private let content: (ToastPresenterProxy) -> Content
    
    public init(
        @ViewBuilder content: @escaping (ToastPresenterProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if toastPresenter.isPresentationEnabled {
                content(toastPresenter)
            }
        }
    }
}

// MARK: Previews

#if ENABLE_PREVIEWS || true

#Preview("Schedule Toast") {
    ToastPresenterReader { proxy in
        let transitionUnderTest = ToastTransition.scale
            .combined(with: .opacity)
        
        Button(proxy.isPresentationEnabled ? "Found" : "Not Found") {
            proxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top,
                toastEnvironmentValues: ToastEnvironmentValues(
                    toastTransition: transitionUnderTest
                )
            )
        }
        .onAppear {
            proxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top,
                toastEnvironmentValues: ToastEnvironmentValues(
                    toastTransition: transitionUnderTest
                )
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(watchOS)
    .toastPresentingLayout()
#endif
}


#Preview("Cancel Scheduled Toasts") {
    ToastPresenterReader { proxy in
        VStack {
            Button("Schedule Toasts") {
                for n in 0..<100 {
                    proxy.schedulePresentation(
                        toast: Toast("Hello Toast! \(n + 1)"),
                        toastAlignment: .top,
                        toastEnvironmentValues: ToastEnvironmentValues(
                            toastTransition: .defaultTransition
                        )
                    )
                }
            }
            
            Button("Cancel Scheduled Presentations") {
                proxy.cancelScheduledPresentations()
            }
        }
    }
#if os(watchOS)
    .toastPresentingLayout()
#endif
}

#endif
