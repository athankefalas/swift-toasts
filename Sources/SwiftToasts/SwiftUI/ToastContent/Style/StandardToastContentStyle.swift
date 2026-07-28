//
//  StandardToastContentStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI

public struct StandardToastContentStyle: ToastContentStyle {
    public nonisolated init() {}
    
    public func makeBody(
        configuration: Configuration
    ) -> some View {
        StyledViewBody(configuration: configuration)
    }
    
    private struct StyledViewBody: View {
        @Environment(\.toastPresentedRole)
        private var toastPresentedRole
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        @Environment(\.toastAccessibilityOptions)
        private var toastAccessibilityOptions
        
        @State
        private var smallIconSize: CGFloat = 24
        
        @State
        private var largeIconSize: CGFloat = 64
        
        let configuration: Configuration
        
        private var tintColor: Color {
            Color.accentColor(for: toastPresentedRole ?? .plain)
        }
        
        private var iconSize: CGFloat {
            return isCenterAligned ? largeIconSize : smallIconSize
        }
        
        private var isCenterAligned: Bool {
            guard let toastPresentedAlignment else {
                return false
            }
            
            return toastPresentedAlignment.rawValue == [] || toastPresentedAlignment.rawValue == .all
        }
        
        var body: some View {
            if isCenterAligned {
                VStack(alignment: .center, spacing: 24) {
                    icon
                    titleAndSubtitle
                }
                .fallbackScaledMetric(24, relativeTo: .title, assingedTo: $smallIconSize)
                .fallbackScaledMetric(64, relativeTo: .title, assingedTo: $largeIconSize)
            } else {
                HStack(alignment: .center, spacing: 12) {
                    icon
                    titleAndSubtitle
                }
                .fallbackScaledMetric(24, relativeTo: .title, assingedTo: $smallIconSize)
                .fallbackScaledMetric(64, relativeTo: .title, assingedTo: $largeIconSize)
            }
        }
        
        private var icon: some View {
            configuration.icon
                .foregroundColor(tintColor)
                .fallbackTintColor(tintColor)
                .font(.system(size: iconSize))
                .toastContentAccessibilityId(\.icon)
                .fallbackAccessibilityHidden(toastAccessibilityOptions.accessibilityIconHidden)
        }
        
        private var titleAndSubtitle: some View {
            VStack(
                alignment: isCenterAligned ? .center : .leading,
                spacing: isCenterAligned ? 8 : 4
            ) {
                configuration.title
                    .foregroundColor(.primary)
                    .font(isCenterAligned ? .fallbackTitle3 : .headline)
                    .toastContentAccessibilityId(\.title)
                
                configuration.subtitle
                    .foregroundColor(.secondary)
                    .font(isCenterAligned ? .fallbackTitle3.weight(.regular) : .callout)
                    .toastContentAccessibilityId(\.subtitle)
            }
        }
    }
}

// MARK: ToastContentStyle Extension

public extension ToastContentStyle where Self == StandardToastContentStyle {
    
    nonisolated static var standard: StandardToastContentStyle {
        StandardToastContentStyle()
    }
}
