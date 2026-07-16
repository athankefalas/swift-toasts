//
//  StyleUtils.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

extension View {
    
    func applyToastControlStyles(
        accentColor: Color,
        isCenterAligned: Bool
    ) -> some View {
        self
            .toastContentStyle(.standard)
            .applyToastLabelStyle(accentColor: accentColor)
            .applyToastLabeledContentStyle()
            .applyToastButtonStyle(accentColor: .accentColor)
            .font(isCenterAligned ? .fallbackTitle3 : .headline)
    }
    
    @ViewBuilder
    func platformDismissalGesture(
        perform action: @escaping () -> Void
    ) -> some View {
#if os(tvOS)
        if #available(tvOS 16, *) {
            self.onTapGesture(perform: action)
        } else {
            self
        }
#else
        self.onTapGesture(perform: action)
#endif
    }
    
    @ViewBuilder
    func glassToastStyle<S: ToastStyle>(orElse fallback: S) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            self.toastStyle(.glass)
        } else {
            self.toastStyle(fallback)
        }
    }
}

extension Color {
    
    static var fallbackSystemBackground: Color {
#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        return Color(UIColor.systemBackground)
#elseif canImport(UIKit) && os(watchOS)
        return Color(UIColor.black)
#elseif canImport(UIKit) && os(tvOS)
        return Color(
            UIColor(dynamicProvider: { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .black : .white
            })
        )
#elseif canImport(Cocoa)
        return Color(NSColor.windowBackgroundColor)
#else
        return Color.clear
#endif
    }
    
    static func accentColor(for role: ToastRole) -> Color {
        switch role {
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
}
