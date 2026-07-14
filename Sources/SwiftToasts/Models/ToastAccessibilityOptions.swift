//
//  ToastAccessibilityOptions.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 13/7/26.
//

import SwiftUI

public nonisolated struct ToastAccessibilityOptions: Sendable {
    
    public struct ToastContentAccessibilityIdentifiers: Sendable {
        public var icon: String?
        public var title: String?
        public var button: String?
        public var subtitle: String?
        public var container: String?
        
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
    
    public var accessibilityHidden: Bool
    public var accessibilityIconHidden: Bool
    public var accessibilityLabel: LabelContent?
    public var accessibilityTraits: AccessibilityTraits
    public var accessibilityManageFocus: Bool
    public var accessibilityIdentifiers: ToastContentAccessibilityIdentifiers
    public var accessibilityDismissActionName: LabelContent?
    public var accessibilityOnAppearAnnouncement: LabelContent?
    public var accessibilityOnDisappearAnnouncement: LabelContent?
    
    
    public init(
        accessibilityHidden: Bool = false,
        accessibilityIconHidden: Bool = true,
        accessibilityLabel: LabelContent? = nil,
        accessibilityTraits: AccessibilityTraits = [.isModal, .updatesFrequently],
        accessibilityManageFocus: Bool = true,
        accessibilityIdentifiers: ToastContentAccessibilityIdentifiers = ToastContentAccessibilityIdentifiers(),
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
    
    public static var hidden: ToastAccessibilityOptions {
        ToastAccessibilityOptions(
            accessibilityHidden: true,
            accessibilityIconHidden: true,
            accessibilityLabel: nil,
            accessibilityTraits: [],
            accessibilityManageFocus: false,
            accessibilityIdentifiers: ToastContentAccessibilityIdentifiers(),
            accessibilityDismissActionName: nil,
            accessibilityOnAppearAnnouncement: nil,
            accessibilityOnDisappearAnnouncement: nil
        )
    }
    
    public static var `default`: ToastAccessibilityOptions {
        ToastAccessibilityOptions()
    }
    
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
