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
    
    @State
    private var isAccessibilityFocused: Bool = false
    
    @State
    private var isHovering = false
    
    let cornerRadius: CGFloat
    let configuration: Configuration
    let toastBackground: (ToastBackgroundProperties) -> ToastBackground
    
    init(
        cornerRadius: CGFloat,
        configuration: Configuration,
        toastBackground: @escaping (ToastBackgroundProperties) -> ToastBackground
    ) {
        self.cornerRadius = cornerRadius
        self.configuration = configuration
        self.toastBackground = toastBackground
    }
    
    private var inset: CGFloat {
        max(12, round(cornerRadius * 0.8))
    }
    
    private var accentColor: Color {
        .accentColor(for: configuration.role)
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
                accentColor: accentColor,
                isCenterAligned: isCenterAligned
            )
            .foregroundColor(.primary)
            .padding(.horizontal, inset)
            .padding(.vertical, inset)
            .frame(
                minWidth: platformIdiom == .watch ? nil : 180,
                maxWidth: platformIdiom == .watch ? .infinity : nil,
                alignment: isCenterAligned ? .center : .leading
            )
            .background(
                toastBackground(
                    ToastBackgroundProperties(
                        accentColor: accentColor,
                        cornerRadius: cornerRadius,
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
            .padding()
            .scaleEffect(isHovering ? 1.05 : 1)
#if !os(tvOS)
            .fallbackOnHover { isHovering = $0 }
#endif
            .animation(.default, value: isHovering)
            .accessibilityElement(children: .contain)
            .fallbackAccessibilitySortPriority(10000)
            .fallbackAccessibilityFocused($isAccessibilityFocused)
            .fallbackAccessibilityAddTraits(toastAccessibilityOptions.accessibilityTraits)
            .fallbackAccessibilityIdentifier(toastAccessibilityOptions.accessibilityIdentifiers.container ?? "")
            .accessibilityDismissAction(
                named: toastAccessibilityOptions.accessibilityDismissActionName,
                when: toastInteractiveDismissEnabled
            ) {
                toastDismiss?()
            }
            .fallbackAccessibilityLabel(toastAccessibilityOptions.accessibilityLabel.flatMap({ Text($0) }) ?? Text(""))
            .fallbackAccessibilityHidden(toastAccessibilityOptions.accessibilityHidden)
            .onAppear {
                Task { @MainActor in
                    try? await Task.sleep(duration: .seconds(0.12))
                    
                    if toastAccessibilityOptions.accessibilityManageFocus {
                        isAccessibilityFocused = true
                    }
                    
                    guard let appearedAnnouncementName = toastAccessibilityOptions.accessibilityOnAppearAnnouncement else {
                        return
                    }
                    
                    FallbackAccessibilityNotification.Announcement.post(appearedAnnouncementName.string)
                }
            }
            .onDisappear {
                Task { @MainActor in
                    try? await Task.sleep(duration: .seconds(0.12))
                    
                    if toastAccessibilityOptions.accessibilityManageFocus {
                        isAccessibilityFocused = false
                    }
                    
                    guard let disappearedAnnouncementName = toastAccessibilityOptions.accessibilityOnDisappearAnnouncement else {
                        return
                    }
                    
                    FallbackAccessibilityNotification.Announcement.post(disappearedAnnouncementName.string)
                }
            }
    }
}

private extension View {
    
    @ViewBuilder
    func accessibilityDismissAction(
        named name: LabelContent?,
        when condition: Bool,
        perform action: @escaping () -> Void
    ) -> some View {
        if !condition {
            self
        } else if let name {
            self.accessibilityAction(named: Text(name), action)
                .accessibilityAction(.escape, action)
        } else {
            self.accessibilityAction(.escape, action)
        }
    }
}
