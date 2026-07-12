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
//                PlainToastBackground(
//                    accentColor: accentColor,
//                    cornerRadius: 12,
//                    borderWidth: borderWidth,
//                    isHovering: isHovering
//                )
                toastBackground(
                    ToastBackgroundProperties(
                        accentColor: accentColor,
                        cornerRadius: 12,
                        borderWidth: borderWidth,
                        isHovering: isHovering
                    )
                )
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
            .fallbackAccessibilityAddTraits([.isModal, .updatesFrequently])
            .fallbackAccessibilityIdentifier("Toast")
    }
}
