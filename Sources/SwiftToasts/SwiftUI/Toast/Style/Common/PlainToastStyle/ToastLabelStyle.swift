//
//  ToastLabelStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/11/24.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ToastLabelStyle: LabelStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            accentColor: accentColor,
            configuration: configuration
        )
    }
    
    private struct StyledViewBody: View {
        
        @ScaledMetric(relativeTo: .title3)
        var iconSize = 24
        
        @ScaledMetric(relativeTo: .title)
        var largeIconSize = 64
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        let accentColor: Color
        let configuration: Configuration
        
        private var isCenterAligned: Bool {
            guard let toastPresentedAlignment else {
                return false
            }
            
            return toastPresentedAlignment.rawValue == [] || toastPresentedAlignment.rawValue == .all
        }
        
        var body: some View {
            if isCenterAligned {
                VStack(spacing: 24) {
                    configuration.icon
                        .foregroundColor(accentColor)
                        .fallbackTintColor(accentColor)
                        .font(.system(size: largeIconSize))
                        .accessibilityIdentifier("ToastIcon")
                    
                    configuration.title
                        .foregroundColor(.primary)
                        .font(.title)
                        .accessibilityIdentifier("ToastContent")
                        .accessibilityElement(children: .contain)
                }
                .padding(12)
            } else {
                HStack(spacing: 12) {
                    configuration.icon
                        .foregroundColor(accentColor)
                        .fallbackTintColor(accentColor)
                        .font(.system(size: iconSize))
                        .accessibilityIdentifier("ToastIcon")
                    
                    configuration.title
                        .foregroundColor(.primary)
                        .font(.title3)
                        .accessibilityIdentifier("ToastContent")
                        .accessibilityElement(children: .contain)
                }
            }
        }
    }
}

extension View {
    
    @ViewBuilder
    func applyToastLabelStyle(
        accentColor: Color
    ) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.labelStyle(ToastLabelStyle(accentColor: accentColor))
        } else {
            self
        }
    }
    
    @ViewBuilder
    fileprivate func fallbackTintColor(_ color: Color) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.tint(color)
        } else {
            self
        }
    }
}
