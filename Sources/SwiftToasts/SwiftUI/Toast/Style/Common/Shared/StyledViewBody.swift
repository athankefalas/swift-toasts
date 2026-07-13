//
//  StyledViewBody.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

struct StyledViewBody<ToastBackground: View>: View {
    typealias Configuration = ToastStyle.Configuration
    
    struct ToastBackgroundProperties {
        let accentColor: Color
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let isHovering: Bool
    }
    
    @Environment(\.toastDismiss)
    private var toastDismiss
    
    @Environment(\.platformIdiom)
    private var platformIdiom
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @Environment(\.toastPresentedAlignment)
    private var toastPresentedAlignment
    
    @Environment(\.toastInteractiveDismissEnabled)
    private var toastInteractiveDismissEnabled
    
    @Environment(\.toastAccessibilityOptions)
    private var toastAccessibilityOptions
    
//    @AccessibilityFocusState
//    private var isAccessibilityElementFocused: Binding<Bool>
    
    @State
    private var isHovering = false
    
    let configuration: Configuration
    let toastBackground: (ToastBackgroundProperties) -> ToastBackground
    
    init(
        configuration: Configuration,
        toastBackground: @escaping (ToastBackgroundProperties) -> ToastBackground
    ) {
        self.configuration = configuration
        self.toastBackground = toastBackground
    }
    
    private var accentColor: Color {
        switch configuration.role {
        case .plain:
            return Color.primary
        case .informational:
            return Color.blue
        case .success:
            return Color.green
        case .warning:
            return Color.yellow
        case .failure:
            return Color.red
        }
    }
    
    private var borderWidth: CGFloat {
        guard platformIdiom == .desktop || platformIdiom == .headset else {
            return isHovering ? 2 : 1
        }
        
        return isHovering ? 3 : 2
    }
    
    private var isCenterAligned: Bool {
        guard let toastPresentedAlignment else {
            return false
        }
        
        return toastPresentedAlignment.rawValue == [] || toastPresentedAlignment.rawValue == .all
    }
    
    var body: some View {
        configuration.content
            .applyToastControlStyles(
                accentColor: accentColor
            )
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(
                minWidth: platformIdiom == .watch ? nil : 180,
                maxWidth: platformIdiom == .watch ? .infinity : nil,
                alignment: isCenterAligned ? .center : .leading
            )
            .background(
                toastBackground(
                    ToastBackgroundProperties(
                        accentColor: accentColor,
                        cornerRadius: 12,
                        borderWidth: borderWidth,
                        isHovering: isHovering
                    )
                )
                .fallbackAccessibilityHidden(true)
            )
            .platformDismissalGesture {
                guard toastInteractiveDismissEnabled else {
                    return
                }
                
                toastDismiss?()
            }
            .scaleEffect(isHovering ? 1.05 : 1)
#if !os(tvOS)
            .fallbackOnHover { isHovering = $0 }
#endif
            .animation(.default, value: isHovering)
            .accessibilityElement(children: .contain)
            .fallbackAccessibilityAddTraits(toastAccessibilityOptions.accessibilityTraits)
            .fallbackAccessibilityIdentifier(toastAccessibilityOptions.accessibilityIdentifier)
            .accessibilityDismissAction(named: toastAccessibilityOptions.accessibilityDismissActionName) {
                toastDismiss?()
            }
            .fallbackAccessibilityLabel(toastAccessibilityOptions.accessibilityLabel.flatMap({ Text($0) }) ?? Text(""))
            .fallbackAccessibilityHidden(toastAccessibilityOptions.accessibilityHidden)
            .onAppear {
                if toastAccessibilityOptions.accessibilityManageFocus {
                    // Gain Focus
                }
                
                guard let appearedAnnouncementName = toastAccessibilityOptions.accessibilityOnAppearAnnouncement else {
                    return
                }
                
                Task { @MainActor in
                    try? await Task.sleep(duration: .seconds(0.3))
                    AccessibilityAnnouncement.announcement(appearedAnnouncementName.string).post()
                }
            }
            .onDisappear {
                if toastAccessibilityOptions.accessibilityManageFocus {
                    // Lose Focus
                }
                
                guard let disappearedAnnouncementName = toastAccessibilityOptions.accessibilityOnDisappearAnnouncement else {
                    return
                }
                
                Task { @MainActor in
                    try? await Task.sleep(duration: .seconds(0.3))
                    AccessibilityAnnouncement.announcement(disappearedAnnouncementName.string).post()
                }
            }
    }
}

private extension View {
    
    func accessibilityDismissAction(named name: LabelContent?, perform action: @escaping () -> Void) -> some View {
        if let name {
            self.accessibilityAction(named: Text(name), action)
        } else {
            self.accessibilityAction(.escape, action)
        }
    }
}

#if canImport(UIKit) && !os(watchOS)
import UIKit

@MainActor
func platformAccessibilityAnnouncement(_ string: String) {
    UIAccessibility.post(notification: .announcement, argument: string)
}

@MainActor
func platformAccessibilityAnnouncement(_ string: NSAttributedString) {
    UIAccessibility.post(notification: .announcement, argument: string)
}


@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
@MainActor
func platformAccessibilityAnnouncement(_ string: AttributedString) {
    UIAccessibility.post(notification: .announcement, argument: string)
}

#elseif canImport(AppKit)
import AppKit

@MainActor
func platformAccessibilityAnnouncement(_ string: String) {
    NSAccessibility.post(element: string, notification: .announcementRequested)
}

@MainActor
func platformAccessibilityAnnouncement(_ string: NSAttributedString) {
    NSAccessibility.post(element: string, notification: .announcementRequested)
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
@MainActor
func platformAccessibilityAnnouncement(_ string: AttributedString) {
    NSAccessibility.post(element: string, notification: .announcementRequested)
}

#else

@MainActor
func platformAccessibilityAnnouncement(_ string: String) {}

@MainActor
func platformAccessibilityAnnouncement(_ string: NSAttributedString) {}


@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
@MainActor
func platformAccessibilityAnnouncement(_ string: AttributedString) {}

#endif

nonisolated struct AccessibilityAnnouncement {
    private let _action: @MainActor () -> Void
    
    private init(
        action: @escaping @MainActor () -> Void
    ) {
        self._action = action
    }
    
    @MainActor
    func callAsFunction() {
        _action()
    }
    
    @MainActor
    func post() {
        _action()
    }
    
    static func announcement(_ string: String) -> Self {
        AccessibilityAnnouncement {
            platformAccessibilityAnnouncement(string)
        }
    }
}
