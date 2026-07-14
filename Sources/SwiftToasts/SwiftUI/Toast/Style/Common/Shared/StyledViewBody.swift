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
            .fallbackAccessibilitySortPriority(.greatestFiniteMagnitude)
            .fallbackAccessibilityAddTraits(toastAccessibilityOptions.accessibilityTraits)
            .fallbackAccessibilityIdentifier(toastAccessibilityOptions.accessibilityIdentifier)
            .accessibilityDismissAction(named: toastAccessibilityOptions.accessibilityDismissActionName) {
                toastDismiss?()
            }
            .fallbackAccessibilityLabel(toastAccessibilityOptions.accessibilityLabel.flatMap({ Text($0) }) ?? Text(""))
            .fallbackAccessibilityHidden(toastAccessibilityOptions.accessibilityHidden)
            .onAppear {
                if toastAccessibilityOptions.accessibilityManageFocus {
                    isAccessibilityFocused = true
                }
                
                guard let appearedAnnouncementName = toastAccessibilityOptions.accessibilityOnAppearAnnouncement else {
                    return
                }
                
                Task { @MainActor in
                    try? await Task.sleep(duration: .seconds(0.3))
                    FallbackAccessibilityNotification.Announcement.post(appearedAnnouncementName.string)
                }
            }
            .onDisappear {
                if toastAccessibilityOptions.accessibilityManageFocus {
                    isAccessibilityFocused = false
                }
                
                guard let disappearedAnnouncementName = toastAccessibilityOptions.accessibilityOnDisappearAnnouncement else {
                    return
                }
                
                Task { @MainActor in
                    try? await Task.sleep(duration: .seconds(0.3))
                    FallbackAccessibilityNotification.Announcement.post(disappearedAnnouncementName.string)
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct AccessibilityFocusModifier: ViewModifier {
    @Binding
    private var isFocused: Bool
    
    @AccessibilityFocusState
    private var isAccessibilityFocused: Bool
    
    init(isFocused: Binding<Bool>) {
        self._isFocused = isFocused
    }
    
    func body(content: Content) -> some View {
        content.accessibilityFocused($isAccessibilityFocused)
            .onChange(of: isAccessibilityFocused) { isAccessibilityFocused in
                isFocused = isAccessibilityFocused
            }
            .onChange(of: isFocused) { isFocused in
                isAccessibilityFocused = isFocused
            }
            .onAppear {
                isAccessibilityFocused = isFocused
            }
    }
}

struct FallbackAccessibilityFocusModifier: ViewModifier {
    @Binding
    private var isFocused: Bool
    
    init(isFocused: Binding<Bool>) {
        self._isFocused = isFocused
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard isFocused else { return }
            FallbackAccessibilityNotification.LayoutChanged.post(.elementWithTag(0))
        }
    }
}

extension View {
    
    @ViewBuilder
    func fallbackAccessibilityFocused(_ isFocused: Binding<Bool>) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.modifier(AccessibilityFocusModifier(isFocused: isFocused))
        } else {
            self.modifier(FallbackAccessibilityFocusModifier(isFocused: isFocused))
        }
    }
}
