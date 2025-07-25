//
//  ToastModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 5/12/24.
//

import SwiftUI
import Combine

private struct ToastModifier<Value: Equatable>: ViewModifier {
    
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
    
    @State
    private var presentationCanceller = ToastPresentationCanceller()
    
    @Binding
    private var value: Value?
    
    private let toastAlignment: ToastAlignment
    private let onToastDismiss: (@MainActor () -> Void)?
    private let toast: (Value) -> Toast?
    
    init(
        value: Binding<Value?>,
        toastAlignment: ToastAlignment,
        onToastDismiss:(@MainActor () -> Void)?,
        toast: @escaping (Value) -> Toast?
    ) {
        self._value = value
        self.toastAlignment = toastAlignment
        self.onToastDismiss = onToastDismiss
        self.toast = toast
    }
    
    func body(content: Content) -> some View {
        content.fallbackOnChange(of: value) { newValue in
            valueChanged(to: newValue)
        }
        .onAppear {
            valueChanged(to: value)
        }
    }
    
    private func valueChanged(to newValue: Value?) {
        guard let newValue else {
            return presentationCanceller.dismissPresentation()
        }
        
        guard let toast = toast(newValue) else {
            return
        }
        
        presentationCanceller.dismissPresentation()
        toastPresenter._schedule(
            presentation: ToastPresentation(
                toast: toast,
                toastAlignment: toastAlignment,
                toastStyle: toastStyle,
                toastTransition: toastTransition,
                presentationCanceller: presentationCanceller,
                onDismiss: {
                    
                    if value == newValue {
                        value = nil
                    }
                    
                    onToastDismiss?()
                }
            ),
            cancellationPolicy: toastCancellation.byReplacingAutomatic(
                with: .presentation
            ),
            cancellables: &cancellables
        )
    }
}

public extension View {
    
    /// Presents a toast when the given binding is toggled to true.
    /// - Parameters:
    ///   - isPresented: The binding controlling the presentation of the Toast.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present.
    func toast(
        isPresented: Binding<Bool>,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping () -> Toast?
    ) -> some View {
        self.modifier(
            ToastModifier(
                value: Binding<Bool?> {
                    isPresented.wrappedValue ? true : nil
                } set: { newValue, transaction in
                    isPresented.transaction(transaction).wrappedValue = newValue != nil
                },
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: {_ in toast() }
            )
        )
    }
    
    /// Presents a toast when the given binding has a non nil value.
    /// - Parameters:
    ///   - item: The binding controlling the presentation of the Toast.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present for the given item.
    func toast<Value: Equatable>(
        item: Binding<Value?>,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping (Value) -> Toast?
    ) -> some View {
        self.modifier(
            ToastModifier(
                value: item,
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: toast
            )
        )
    }
}

#if DEBUG

struct _ToastPresentationByFlagModifierPreview: View {
    
    @State
    var showToast = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(verbatim: "Show Toast: \(showToast)")
            
            Button("Show") {
                showToast = true
            }
            
            Button("Hide") {
                showToast = false
            }
            
            Spacer()
        }
        .padding()
        .toast(isPresented: $showToast) {
            Toast("Hello world!")
        }
    }
}

struct _ToastPresentationByValueModifierPreview: View {
    
    @State
    var item: UUID?
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(verbatim: "Item: \(item?.uuidString ?? "-")")
            
            Button("Make Item") {
                item = UUID()
            }
            
            Button("Clear") {
                item = nil
            }
            
            Spacer()
        }
        .padding()
        .toast(item: $item) { item in
            Toast("Hello world!")
        }
    }
}

#Preview("Toast Presentation By Flag") {
    _ToastPresentationByFlagModifierPreview()
}

#Preview("Toast Presentation By Value") {
    _ToastPresentationByValueModifierPreview()
}

#endif
