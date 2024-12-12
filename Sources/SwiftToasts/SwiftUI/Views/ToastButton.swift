//
//  ToastButton.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// A button that will display a toast after perfoming it's action.
public struct ToastButton<Label: View>: View {
    
    private struct ButtonRoleBox {
        let erasedRole: Any?
        
        init() {
            erasedRole = nil
        }
        
        @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        init(wrapping role: ButtonRole?) {
            self.erasedRole = role
        }
        
        @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        func unwrap() -> ButtonRole? {
            guard let erasedRole else {
                return nil
            }
            
            guard let role = erasedRole as? ButtonRole else {
                preconditionFailure()
            }
            
            return role
        }
    }
    
    @Environment(\.toastPresenter)
    private var toastPresenter
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    @Environment(\.toastTransition)
    private var toastTransition
    
    @Environment(\.toastCancellation)
    private var toastCancellation
    
    @PresentationBoundState
    private var cancellablesBox = CancellablesBox()
    
    private let role: ButtonRoleBox
    private let action: @MainActor (ScheduleToastAction) -> Void
    private let label: Label
    
    init(
        action: @escaping @MainActor (ScheduleToastAction) -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.role = ButtonRoleBox()
        self.action = action
        self.label = label()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    init(
        role: ButtonRole? = nil,
        action: @escaping @MainActor (ScheduleToastAction) -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.role = ButtonRoleBox(wrapping: role)
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        makeErasedButtonBody()
    }
    
    private func makeErasedButtonBody() -> Button<Label> {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return makeButtonWithRole()
        } else {
            return makeFallbackButton()
        }
    }
    
    private func makeFallbackButton() -> Button<Label> {
        Button {
            action(
                ScheduleToastAction(
                    toastPresenterProxy: toastPresenter,
                    toastStyle: toastStyle,
                    toastTransition: toastTransition,
                    toastCancellation: toastCancellation,
                    preferredCancellation: .presentation,
                    cancellablesBox: cancellablesBox
                )
            )
        } label: {
            label
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private func makeButtonWithRole() -> Button<Label> {
        Button(role: role.unwrap()) {
            action(
                ScheduleToastAction(
                    toastPresenterProxy: toastPresenter,
                    toastStyle: toastStyle,
                    toastTransition: toastTransition,
                    toastCancellation: toastCancellation,
                    preferredCancellation: .presentation,
                    cancellablesBox: cancellablesBox
                )
            )
        } label: {
            label
        }
    }
}

// MARK: Previews

#if DEBUG

#Preview("Simple Button") {
    ToastButton { proxy in
        proxy.schedule(toast: Toast("Toast"))
    } label: {
        Text("Toast")
    }
}

#Preview("Simple Button + Leaking") {
    ToastButton { proxy in
        Task {
            try await Task.sleep(seconds: 5)
            proxy.schedule(toast: Toast("Toast"))
        }
    } label: {
        Text("Toast")
    }
}

#Preview("Presented Button") {
    PresentedPreview {
        
        ToastButton { proxy in
            proxy.schedule(toast: Toast("Toast"))
        } label: {
            Text("Top Toast")
        }
        
        ToastButton { proxy in
            Task {
                try await Task.sleep(seconds: 5)
                proxy.schedule(toast: Toast("Toast"))
            }
        } label: {
            Text("Leaky Top Toast")
        }
        
        ToastButton { proxy in
            proxy.schedule(toast: Toast("Toast"), alignment: .bottom)
        } label: {
            Text("Bottom Toast")
        }
    }
}

#Preview("Presented Button + No Cancellation") {
    PresentedPreview {
        ToastButton { proxy in
            proxy.schedule(toast: Toast("Toast"))
        } label: {
            Text("Top Toast")
        }
        
        ToastButton { proxy in
            Task {
                try await Task.sleep(seconds: 5)
                proxy.schedule(toast: Toast("Toast"))
            }
        } label: {
            Text("Leaky Top Toast")
        }
        
        ToastButton { proxy in
            proxy.schedule(toast: Toast("Toast"), alignment: .bottom)
        } label: {
            Text("Bottom Toast")
        }
    }
    .toastCancellation(.never)
}

#endif

