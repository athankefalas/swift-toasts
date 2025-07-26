//
//  ToastTriggerModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

private struct ToastTriggerModifier<Trigger: Equatable>: ViewModifier {
    
    @Environment(\.toastPresenter)
    private var toastPresenter
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    @Environment(\.toastTransition)
    private var toastTransition
    
    @Environment(\.toastCancellation)
    private var toastCancellation
    
    @Environment(\.toastPresentationInvalidation)
    private var toastPresentationInvalidation
    
    @PresentationBoundState
    private var cancellables: Set<AnyCancellable> = []
    
    @State
    private var presentationCanceller = ToastPresentationCanceller()
    
    private let trigger: Trigger
    private let toastAlignment: ToastAlignment
    private let onToastDismiss: (@MainActor () -> Void)?
    private let toast: (Trigger) -> Toast?
    
    private var invalidationOptions: ToastPresentationInvalidationOptions {
        toastPresentationInvalidation ?? .contextChanged
    }
    
    init(
        trigger: Trigger,
        toastAlignment: ToastAlignment,
        onToastDismiss:(@MainActor () -> Void)?,
        toast: @escaping (Trigger) -> Toast?
    ) {
        self.trigger = trigger
        self.toastAlignment = toastAlignment
        self.onToastDismiss = onToastDismiss
        self.toast = toast
    }
    
    func body(content: Content) -> some View {
        content.fallbackOnChange(of: trigger) { newValue in
            guard let toast = toast(newValue) else {
                return
            }
            
            if invalidationOptions.contains(.contextChanged) {
                presentationCanceller.dismissPresentation()
            }
            
            toastPresenter._schedule(
                presentation: ToastPresentation(
                    toast: toast,
                    toastAlignment: toastAlignment,
                    toastStyle: toastStyle,
                    toastTransition: toastTransition,
                    presentationCanceller: presentationCanceller,
                    onDismiss: onToastDismiss
                ),
                cancellationPolicy: toastCancellation.byReplacingAutomatic(
                    with: .presentation
                ),
                cancellables: &cancellables
            )
        }
        .fallbackOnChange(of: invalidationOptions) { newValue in
            presentationCanceller.dismissOnDeinit = newValue.contains(.presentationDismissed)
        }
        .onAppear {
            presentationCanceller.dismissOnDeinit = invalidationOptions.contains(.presentationDismissed)
        }
    }
}

public extension View {
    
    /// Presents a Toast when the given trigger value changes.
    /// - Parameters:
    ///   - trigger: The value that triggers the Toast presentation.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present.
    func toast<Trigger: Equatable>(
        trigger: Trigger,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping (Trigger) -> Toast?
    ) -> some View {
        self.modifier(
            ToastTriggerModifier(
                trigger: trigger,
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: toast
            )
        )
    }
    
    /// Presents a Toast when the given trigger value changes.
    /// - Parameters:
    ///   - trigger: The value that triggers the Toast presentation.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present for the latest trigger value.
    func toast<Trigger: Equatable>(
        trigger: Trigger,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping () -> Toast?
    ) -> some View {
        self.modifier(
            ToastTriggerModifier(
                trigger: trigger,
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: {_ in toast() }
            )
        )
    }
}

// MARK: Previews

#if DEBUG

struct _ToastTriggerModifierPreview: View {
    
    @State
    private var isOn = false
    
    var body: some View {
        VStack {
            Toggle("Some option", isOn: $isOn)
                .toast(trigger: isOn) { newValue in
                    if newValue {
                        Toast("Option changed to \(newValue)")
                    }
                }
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    PreviewContent {
        _ToastTriggerModifierPreview()
    }
}

#endif
