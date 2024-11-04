//
//  ToastTriggerModifier.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
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
    
    @PresentationBoundState
    private var cancellables: Set<AnyCancellable> = []
    
    private let trigger: Trigger
    private let toastAlignment: ToastAlignment
    private let onToastDismiss: (@MainActor () -> Void)?
    private let toast: (Trigger) -> Toast?
    
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
            
            toastPresenter._schedule(
                presentation: ToastPresentation(
                    toast: toast,
                    toastAlignment: toastAlignment,
                    toastStyle: toastStyle,
                    toastTransition: toastTransition,
                    onDismiss: onToastDismiss
                ),
                cancellationPolicy: toastCancellation.byReplacingAutomatic(
                    with: .presentation
                ),
                cancellables: &cancellables
            )
        }
    }
}

public extension View {
    
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
        Toggle("Some option", isOn: $isOn)
            .toast(trigger: isOn) { newValue in
                if newValue {
                    Toast("Option changed to \(newValue)")
                }
            }
    }
}

#Preview {
    PreviewContent {
        _ToastTriggerModifierPreview()
    }
}

#endif
