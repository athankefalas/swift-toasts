//
//  ToastAccessibilityOptionsEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 13/7/26.
//

import SwiftUI


private struct ToastAccessibilityOptionsEnvironmentKey: EnvironmentKey {
    public static let defaultValue: ToastAccessibilityOptions = ToastAccessibilityOptions()
}

public extension EnvironmentValues {
    
    /// A variety of options that controls the accessibility attributes of a presented toast.
    internal(set) var toastAccessibilityOptions: ToastAccessibilityOptions {
        get { self[ToastAccessibilityOptionsEnvironmentKey.self] }
        set { self[ToastAccessibilityOptionsEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Controls the accessibility options for a `Toast` presented by this environment.
    /// - Parameter options: The accessibility options to use
    /// - Returns: A modifed view.
    func toastAccessibilityOptions(_ options: ToastAccessibilityOptions) -> some View {
        self.environment(\.toastAccessibilityOptions, options)
    }
    
    /// Controls if the presented `Toast` will be hidden from the accessibility system.
    /// - Parameters:
    ///   - hidden: A flag that controls if a Toast will be hidden
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityHidden(_ hidden: Bool, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            guard isEnabled else { return }
            value.accessibilityHidden = hidden
        }
    }
    
    /// Controls if the icon of a presented `Toast` will be hidden from the accessibility system.
    /// - Parameters:
    ///   - iconHidden: A flag that controls if a Toast icon will be hidden
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityIconHidden(_ iconHidden: Bool, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            guard isEnabled else { return }
            value.accessibilityIconHidden = iconHidden
        }
    }
    
    /// Controls the accesibility label used to describe the contents of a `Toast`.
    /// - Parameters:
    ///   - label: The label content to use.
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityLabel(_ label: LabelContent?, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            value.accessibilityLabel = isEnabled ? label : value.accessibilityLabel
        }
    }
    
    /// Controls the accesibility traits applied to a `Toast`.
    /// - Parameters:
    ///   - traits: The traits to apply.
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityTraits(_ traits: AccessibilityTraits, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            guard isEnabled else { return }
            value.accessibilityTraits = traits
        }
    }
    
    /// Controls whether a `Toast` will automatically gain accesibility focus when presented and give it up when dismissed.
    /// - Parameters:
    ///   - manageFocus: A flag that controls if the Toast will manage its accessibility focus.
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityManagesFocus(_ manageFocus: Bool, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            guard isEnabled else { return }
            value.accessibilityManageFocus = manageFocus
        }
    }
    
    /// Controls the identifier a `Toast` will have in the accessibility system.
    /// - Parameters:
    ///   - identifier: The identifier to use
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityIdentifier(_ identifier: String, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            guard isEnabled else { return }
            value.accessibilityIdentifier = identifier
        }
    }
    
    /// Controls the label used for an accesibility action that can dismiss a presented `Toast`.
    /// - Parameters:
    ///   - name: The label content to use as the action name.
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityDismissActionName(_ name: LabelContent?, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            value.accessibilityDismissActionName = isEnabled ? name : value.accessibilityDismissActionName
        }
    }
    
    /// Controls the content of an assistive announcement published when a `Toast` is presented.
    /// - Parameters:
    ///   - announcement: The label content to use as the announcement.
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityAppearedAnnouncement(_ announcement: LabelContent?, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            value.accessibilityOnAppearAnnouncement = isEnabled ? announcement : value.accessibilityOnAppearAnnouncement
        }
    }
    
    /// Controls the content of an assistive announcement published when a `Toast` is dismissed.
    /// - Parameters:
    ///   - announcement: The label content to use as the announcement.
    ///   - isEnabled: If true the accessibility hidden state is applied;
    ///     otherwise the accessibility hidden state is unchanged.
    /// - Returns: A modifed view.
    func toastAccessibilityDisappearedAnnouncement(_ announcement: LabelContent?, isEnabled: Bool = true) -> some View {
        self.transformEnvironment(\.toastAccessibilityOptions) { value in
            value.accessibilityOnDisappearAnnouncement = isEnabled ? announcement : value.accessibilityOnDisappearAnnouncement
        }
    }
}
