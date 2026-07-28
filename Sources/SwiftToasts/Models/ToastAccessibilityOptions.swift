//
//  ToastAccessibilityOptions.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 13/7/26.
//

import SwiftUI

/// The accessibility options used to configure the content of a toast.
public nonisolated struct ToastAccessibilityOptions: Sendable {
    
    /// A type that contains the identifiers for the contents of a toast.
    public struct AccessibilityIdentifiers: Sendable {
        /// The accessibility identifier for a toast icon.
        public var icon: String?
        /// The accessibility identifier for a toast title.
        public var title: String?
        /// The accessibility identifier for a toast button.
        public var button: String?
        /// The accessibility identifier for a button contained inside a toast.
        public var subtitle: String?
        /// The accessibility identifier for the content container of a toast.
        public var container: String?
        
        /// Create a new set of accessbility identifiers for the content of a toast.
        /// - Parameters:
        ///   - icon: The accessibility identifier for a toast icon.
        ///   - title: The accessibility identifier for a toast title.
        ///   - button: The accessibility identifier for a toast button.
        ///   - subtitle: The accessibility identifier for a button contained inside a toast.
        ///   - container: The accessibility identifier for the content container of a toast.
        public init(
            icon: String? = "ToastIcon",
            title: String? = "ToastTitle",
            button: String? = "ToastButton",
            subtitle: String? = "ToastSubtitle",
            container: String? = "Toast"
        ) {
            self.icon = icon
            self.title = title
            self.button = button
            self.subtitle = subtitle
            self.container = container
        }
    }
    
    /// Controls whether the toast will be hidden from the accessibility system.
    public var accessibilityHidden: Bool
    /// Controls whether a toast icon be hidden from the accessibility system.
    public var accessibilityIconHidden: Bool
    /// The accessibility label to use for the toast.
    public var accessibilityLabel: LabelContent?
    /// The accessibility traits to apply to a toast.
    public var accessibilityTraits: AccessibilityTraits
    /// Controls if the toast will automatically gain and lose accessibility focus when presented.
    public var accessibilityManageFocus: Bool
    /// The content identifiers used to identify the content of a toast.
    public var accessibilityIdentifiers: AccessibilityIdentifiers
    /// A name for an optional accessibility action used to dismiss a toast.
    public var accessibilityDismissActionName: LabelContent?
    /// An optional accessibility announcement used when a toast is presented.
    public var accessibilityOnAppearAnnouncement: LabelContent?
    /// An optional accessibility announcement used when a toast is dismissed.
    public var accessibilityOnDisappearAnnouncement: LabelContent?
    
    /// Create a new set of accessibility options.
    /// - Parameters:
    ///   - accessibilityHidden: Controls whether the toast will be hidden from the accessibility system.
    ///   - accessibilityIconHidden: Controls whether a toast icon be hidden from the accessibility system.
    ///   - accessibilityLabel: The accessibility label to use for the toast.
    ///   - accessibilityTraits: The accessibility traits to apply to a toast.
    ///   - accessibilityManageFocus: Controls if the toast will automatically gain and lose accessibility focus when presented.
    ///   - accessibilityIdentifiers: The content identifiers used to identify the content of a toast.
    ///   - accessibilityDismissActionName: A name for an optional accessibility action used to dismiss a toast.
    ///   - accessibilityOnAppearAnnouncement: An optional accessibility announcement used when a toast is presented.
    ///   - accessibilityOnDisappearAnnouncement: An optional accessibility announcement used when a toast is dismissed.
    public init(
        accessibilityHidden: Bool = false,
        accessibilityIconHidden: Bool = true,
        accessibilityLabel: LabelContent? = nil,
        accessibilityTraits: AccessibilityTraits = [.isModal, .updatesFrequently],
        accessibilityManageFocus: Bool = true,
        accessibilityIdentifiers: AccessibilityIdentifiers = AccessibilityIdentifiers(),
        accessibilityDismissActionName: LabelContent? = nil,
        accessibilityOnAppearAnnouncement: LabelContent? = nil,
        accessibilityOnDisappearAnnouncement: LabelContent? = nil
    ) {
        self.accessibilityHidden = accessibilityHidden
        self.accessibilityIconHidden = accessibilityIconHidden
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityTraits = accessibilityTraits
        self.accessibilityManageFocus = accessibilityManageFocus
        self.accessibilityIdentifiers = accessibilityIdentifiers
        self.accessibilityDismissActionName = accessibilityDismissActionName
        self.accessibilityOnAppearAnnouncement = accessibilityOnAppearAnnouncement
        self.accessibilityOnDisappearAnnouncement = accessibilityOnDisappearAnnouncement
    }
    
    /// A set of accessibility options that hide a toast from the accessibility system.
    public static var hidden: ToastAccessibilityOptions {
        ToastAccessibilityOptions(
            accessibilityHidden: true,
            accessibilityIconHidden: true,
            accessibilityLabel: nil,
            accessibilityTraits: [],
            accessibilityManageFocus: false,
            accessibilityIdentifiers: AccessibilityIdentifiers(),
            accessibilityDismissActionName: nil,
            accessibilityOnAppearAnnouncement: nil,
            accessibilityOnDisappearAnnouncement: nil
        )
    }
    
    /// A set of accessibility options that make a toast visible to the accessibility system.
    public static var visible: ToastAccessibilityOptions {
        ToastAccessibilityOptions()
    }
    
    /// A set of accessibility options that make a toast visible to the accessibility system adding
    /// a specialized dismiss accessibility action and accessibility announcements.
    /// - Parameters:
    ///   - accessibilityDismissActionName: A name for an optional accessibility action used to dismiss a toast.
    ///   - accessibilityOnAppearAnnouncement: An optional accessibility announcement used when a toast is presented.
    ///   - accessibilityOnDisappearAnnouncement: An optional accessibility announcement used when a toast is dismissed.
    public static func accessible(
        dismissActionName accessibilityDismissActionName: LabelContent,
        appearanceAnnouncement accessibilityOnAppearAnnouncement: LabelContent,
        disappearanceAnnouncement accessibilityOnDisappearAnnouncement: LabelContent? = nil
    ) -> ToastAccessibilityOptions {
        ToastAccessibilityOptions(
            accessibilityDismissActionName: accessibilityDismissActionName,
            accessibilityOnAppearAnnouncement: accessibilityOnAppearAnnouncement,
            accessibilityOnDisappearAnnouncement: accessibilityOnDisappearAnnouncement
        )
    }
}
