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
                VStack {
                    content(innerToastPresenter)
                }
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

#if ENABLE_PREVIEWS

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
}

#endif

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Scene {
    
    func toastPresentingScene() -> some Scene {
        self
    }
}


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ToastPresentingScene<Wrapped: Scene>: Scene {
    let wrappedScene: Wrapped
    
    var body: some Scene {
        wrappedScene
            
    }
}
