//
//  GlassToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct GlassToastStyle: ToastStyle {
    public nonisolated init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(configuration: configuration) { properties in
            GlassToastBackground(
                accentColor: properties.accentColor,
                cornerRadius: properties.cornerRadius,
                borderWidth: properties.borderWidth,
                isHovering: properties.isHovering
            )
        }
    }
}

// MARK: ToastStyle Extension

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public extension ToastStyle where Self == GlassToastStyle {
    
    nonisolated static var glass: GlassToastStyle {
        GlassToastStyle()
    }
}
