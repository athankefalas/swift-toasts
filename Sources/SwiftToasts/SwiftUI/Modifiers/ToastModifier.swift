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
    
    @Environment(\.toastPresentationInvalidation)
    private var toastPresentationInvalidation
    
    @PresentationBoundState
    private var cancellables: Set<AnyCancellable> = []
    
    @FallbackStateObject
    private var presentationCanceller = ToastPresentationCanceller()
    
    @State
    private var appeared: Bool = false
    
    @Binding
    private var value: Value?
    
    private let toastAlignment: ToastAlignment
    private let onToastDismiss: (@MainActor (Value) -> Void)?
    private let toast: (Value) -> Toast?
    
    private var invalidationOptions: ToastPresentationInvalidationOptions {
        toastPresentationInvalidation ?? []
    }
    
    init(
        value: Binding<Value?>,
        toastAlignment: ToastAlignment,
        onToastDismiss: (@MainActor (Value) -> Void)?,
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
        .fallbackOnChange(of: invalidationOptions) { newValue in
            presentationCanceller.dismissOnDeinit = newValue.contains(.presentationDismissed)
        }
        .onAppear {
            guard !appeared else {
                return
            }
            
            appeared = true
            valueChanged(to: value)
            presentationCanceller.dismissOnDeinit = invalidationOptions.contains(.presentationDismissed)
        }
    }
    
    private func valueChanged(to newValue: Value?) {
        guard let newValue else {
            return presentationCanceller.dismissPresentation()
        }
        
        guard let toast = toast(newValue) else {
            return
        }
        
        let onToastDismiss = onToastDismiss
        presentationCanceller.dismissPresentation()
        toastPresenter._schedule(
            presentation: ToastPresentation(
                toast: toast,
                toastAlignment: toastAlignment,
                toastStyle: toastStyle,
                toastTransition: toastTransition,
                presentationCanceller: presentationCanceller,
                onDismiss: {
                    onToastDismiss?(newValue)
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
                onToastDismiss: { dismissedValue in
                    if dismissedValue == isPresented.wrappedValue {
                        isPresented.wrappedValue = false
                    }
                    
                    onDismiss?()
                },
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
                onToastDismiss: { dismissedValue in
                    if dismissedValue == item.wrappedValue {
                        item.wrappedValue = nil
                    }
                    
                    onDismiss?()
                },
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
            
            NavigationLink("Details") {
                Text("Details")
            }
            
            Spacer()
        }
        .padding()
        .toast(isPresented: $showToast) {
            Toast("Hello world!")
        }
        .toastPresentationInvalidation(.presentationDismissed)
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
            
            NavigationLink("Details") {
                Text("Details")
            }
            
            Spacer()
        }
        .padding()
        .toast(item: $item) { item in
            Toast("Hello world!")
        }
        .toastPresentationInvalidation(.presentationDismissed)
    }
}

#Preview("Toast Presentation By Flag") {
    PresentedPreview {
        _ToastPresentationByFlagModifierPreview()
    }
}

#Preview("Toast Presentation By Value") {
    PresentedPreview {
        _ToastPresentationByValueModifierPreview()
    }
}

#endif
