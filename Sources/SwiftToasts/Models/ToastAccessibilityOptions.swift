//
//  ToastAccessibilityOptions.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 13/7/26.
//

import SwiftUI

public nonisolated struct ToastAccessibilityOptions: Sendable {
    public var accessibilityHidden: Bool
    public var accessibilityIconHidden: Bool
    public var accessibilityLabel: LabelContent?
    public var accessibilityTraits: AccessibilityTraits
    public var accessibilityManageFocus: Bool
    public var accessibilityIdentifier: String // TODO: Use struct for all elements ???
    public var accessibilityDismissActionName: LabelContent?
    public var accessibilityOnAppearAnnouncement: LabelContent?
    public var accessibilityOnDisappearAnnouncement: LabelContent?
    
    
    public init(
        accessibilityHidden: Bool = false,
        accessibilityIconHidden: Bool = true,
        accessibilityLabel: LabelContent? = nil,
        accessibilityTraits: AccessibilityTraits = [.isModal, .updatesFrequently],
        accessibilityManageFocus: Bool = true,
        accessibilityIdentifier: String = "Toast",
        accessibilityDismissActionName: LabelContent? = nil,
        accessibilityOnAppearAnnouncement: LabelContent? = nil,
        accessibilityOnDisappearAnnouncement: LabelContent? = nil
    ) {
        self.accessibilityHidden = accessibilityHidden
        self.accessibilityIconHidden = accessibilityIconHidden
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityTraits = accessibilityTraits
        self.accessibilityManageFocus = accessibilityManageFocus
        self.accessibilityIdentifier = accessibilityIdentifier
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
            accessibilityIdentifier: "",
            accessibilityDismissActionName: nil,
            accessibilityOnAppearAnnouncement: nil,
            accessibilityOnDisappearAnnouncement: nil
        )
    }
    
    public static var `default`: ToastAccessibilityOptions {
        ToastAccessibilityOptions()
    }
    
    public static func preferred(
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
