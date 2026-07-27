//
//  OpaqueToastBackground.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/11/24.
//

import SwiftUI

struct OpaqueToastBackground: View {
    @Environment(\.platformIdiom)
    private var platformIdiom
    
    @Environment(\.accessibilityReduceTransparency)
    private var accessibilityReduceTransparency
    
    @Environment(\.toastOrnamentPresentationEnabled)
    private var toastOrnamentPresentationEnabled
    
    let accentColor: Color
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let isHovering: Bool
    let useTintedBackground: Bool
    
    private var shadowColor: Color {
        let shadowColor = Color(
            .sRGBLinear,
            white: 0,
            opacity: platformIdiom == .desktop ? 0.2 : 0.17
        )
        
        guard !accessibilityReduceTransparency else {
            return .clear
        }
        
        return shadowColor
    }
    
    private var shadowRadius: CGFloat {
        isHovering ? 24 : 16
    }
    
    private var usesGlassBackgroundEffect: Bool {
#if os(visionOS)
        if toastOrnamentPresentationEnabled {
            return true
        }
#endif
        
        return false
    }
    
    var body: some View {
        ZStack {
            if !usesGlassBackgroundEffect {
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    shape.fill(.background)
                } else {
                    shape.fill(Color.fallbackSystemBackground)
                }
                
                if useTintedBackground {
                    shape.fill(accentColor.opacity(0.1))
                }
                
                shape
                    .stroke(
                        accentColor.opacity(0.5),
                        lineWidth: borderWidth
                    )
                    .layoutPriority(-1)
            }
            
            Color(white: 1, opacity: 0.01)
                .allowsHitTesting(true)
                .contentShape(shape)
        }
        .shadow(
            color: usesGlassBackgroundEffect ? .clear : shadowColor,
            radius: usesGlassBackgroundEffect ? 0 : shadowRadius
        )
        .contentShape(shape)
    }
    
    private var shape: FallbackAnyShape {
        return FallbackAnyShape(
            RoundedRectangle(
                cornerRadius: cornerRadius
            )
        )
    }
}

#if ENABLE_PREVIEWS

#Preview {
    VStack {
        Spacer()
        
        PlainToastBackground(
            accentColor: .blue,
            cornerRadius: 12,
            borderWidth: 2,
            isHovering: false,
            useTintedBackground: true
        )
        .padding(32)
        .border(Color.black)
        .padding()
        
        Spacer()
    }
    .background(
        LinearGradient(
            colors: [.red, .green, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

#endif
