//
//  ToastButton.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// A button that may display a toast after perfoming it's action.
public struct ToastButton<Label: View>: View {
    public typealias Action = @MainActor (ScheduleToastAction) -> Void
    
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
    
    @Environment(\.toastInteractiveDismissEnabled)
    private var toastInteractiveDismissEnabled
    
    @PresentationBoundState
    private var cancellablesBox = CancellablesBox()
    
    private let role: ButtonRoleBox
    private let action: Action
    private let label: Label
    
    /// Creates a button with the given label that performs the given action which may present a `Toast`.
    ///
    /// - Parameters:
    ///   - action: The action to perform when the user triggers the button.
    ///   - label: The label of the button.
    init(
        action: @escaping Action,
        @ViewBuilder label: () -> Label
    ) {
        self.role = ButtonRoleBox()
        self.action = action
        self.label = label()
    }
    
    /// Creates a button with the given label that performs the given action which may present a `Toast`.
    ///
    /// - Parameters:
    ///   - role: The buttons role.
    ///   - action: The action to perform when the user triggers the button.
    ///   - label: The label of the button.
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
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private func makeButtonWithRole() -> Button<Label> {
        Button(role: role.unwrap()) {
            action(
                ScheduleToastAction(
                    toastPresenterProxy: toastPresenter,
                    toastEnvironmentValues: ToastEnvironmentValues(
                        toastStyle: toastStyle,
                        toastTransition: toastTransition,
                        toastInteractiveDismissEnabled: toastInteractiveDismissEnabled
                    ),
                    toastCancellation: toastCancellation,
                    preferredCancellation: .presentation,
                    cancellablesBox: cancellablesBox
                )
            )
        } label: {
            label
        }
    }
    
    private func makeFallbackButton() -> Button<Label> {
        Button {
            action(
                ScheduleToastAction(
                    toastPresenterProxy: toastPresenter,
                    toastEnvironmentValues: ToastEnvironmentValues(
                        toastStyle: toastStyle,
                        toastTransition: toastTransition,
                        toastInteractiveDismissEnabled: toastInteractiveDismissEnabled
                    ),
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ToastButton where Label == Text {

    /// Creates a button that generates its label from a localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - action: The action to perform when the user triggers the button.
    init(
        _ titleKey: LocalizedStringKey,
        action: @escaping Action
    ) {
        self = ToastButton(action: action) {
            Text(titleKey)
        }
    }

    /// Creates a button that generates its label from a string.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - action: The action to perform when the user triggers the button.
    init<S>(
        _ title: S,
        action: @escaping Action
    ) where S : StringProtocol {
        self = ToastButton(action: action) {
            Text(title)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension ToastButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a button that generates its label from a localized string key
    /// and system image name.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        action: @escaping Action
    ) {
        self = ToastButton(action: action) {
            Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates a button that generates its label from a string and
    /// system image name.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    init<S>(
        _ title: S,
        systemImage: String,
        action: @escaping Action
    ) where S : StringProtocol {
        self = ToastButton(action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension ToastButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a button that generates its label from a localized string key
    /// and image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        action: @escaping Action
    ) {
        self = ToastButton(action: action) {
            Label(titleKey, image: image)
        }
    }

    /// Creates a button that generates its label from a string and
    /// image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    init<S>(
        _ title: S,
        image: ImageResource,
        action: @escaping Action
    ) where S : StringProtocol {
        self = ToastButton(action: action) {
            Label(title, image: image)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension ToastButton where Label == Text {

    /// Creates a button with a specified role that generates its label from a
    /// localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user triggers the button.
    init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole?,
        action: @escaping Action
    ) {
        self = ToastButton(role: role, action: action) {
            Text(titleKey)
        }
    }

    /// Creates a button with a specified role that generates its label from a
    /// string.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    init<S>(
        _ title: S,
        role: ButtonRole?,
        action: @escaping Action
    ) where S : StringProtocol {
        self = ToastButton(role: role, action: action) {
            Text(title)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension ToastButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a button with a specified role that generates its label from a
    /// localized string key and a system image.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user triggers the button.
    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole?,
        action: @escaping Action
    ) {
        self = ToastButton(role: role, action: action) {
            Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates a button with a specified role that generates its label from a
    /// string and a system image and an image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    init<S>(
        _ title: S,
        systemImage: String,
        role: ButtonRole?,
        action: @escaping Action
    ) where S : StringProtocol {
        self = ToastButton(role: role, action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension ToastButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a button with a specified role that generates its label from a
    /// localized string key and an image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user triggers the button.
    init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole?,
        action: @escaping Action
    ) {
        self = ToastButton(role: role, action: action) {
            Label(titleKey, image: image)
        }
    }

    /// Creates a button with a specified role that generates its label from a
    /// string and an image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    init<S>(
        _ title: S,
        image: ImageResource,
        role: ButtonRole?,
        action: @escaping Action
    ) where S : StringProtocol {
        self = ToastButton(role: role, action: action) {
            Label(title, image: image)
        }
    }
}

#if DEBUG

#Preview("Simple Button") {
    ToastButton { proxy in
        proxy.schedule(toast: Toast("Toast", duration: .indefinite))
    } label: {
        Text("Toast")
    }
    .padding()
    .background(Color.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(colors: [.red, .green, .blue], startPoint: .leading, endPoint: .trailing)
    )
}

#Preview("Simple Button + Leaking") {
    ToastButton("Toast") { proxy in
        Task {
            try await Task.sleep(seconds: 5)
            proxy.schedule(toast: Toast("Toast"))
        }
    }
}

#Preview("Presented Button") {
    PresentedPreview {
        
        ToastButton("Top Toast") { proxy in
            proxy.schedule(toast: Toast("Toast"))
        }
        
        ToastButton("Leaky Top Toast") { proxy in
            Task {
                try await Task.sleep(seconds: 5)
                proxy.schedule(toast: Toast("Toast"))
            }
        }
        
        ToastButton("Bottom Toast") { proxy in
            proxy.schedule(toast: Toast("Toast"), alignment: .bottom)
        }
    }
}

#Preview("Presented Button + No Cancellation") {
    PresentedPreview {
        
        ToastButton("Top Toast") { proxy in
            proxy.schedule(toast: Toast("Toast"))
        }
        
        ToastButton("Leaky Top Toast") { proxy in
            Task {
                try await Task.sleep(seconds: 5)
                proxy.schedule(toast: Toast("Toast"))
            }
        }
        
        ToastButton("Bottom Toast") { proxy in
            proxy.schedule(toast: Toast("Toast"), alignment: .bottom)
        }
    }
    .toastCancellation(.never)
}

#endif

