//
//  GlassToastBackground.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct GlassToastBackground: View {
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
    let useTintedGlass: Bool
    let useInteractiveGlass: Bool
    
#if !os(visionOS)
    private var glass: Glass {
        var glass = Glass.regular
        
        if useTintedGlass {
            glass = glass.tint(accentColor.opacity(0.1))
        }
        
        if useInteractiveGlass {
            glass = glass.interactive()
        }
        
        return glass
    }
#endif

    var body: some View {
        content
#if os(visionOS)
            .glassBackgroundEffect(
                displayMode: toastOrnamentPresentationEnabled ? .never : .always
            )
#else
            .glassEffect(glass, in: shape)
#endif
            .contentShape(shape)
    }
    
    private var content: some View {
        ZStack {
            if accessibilityReduceTransparency {
                shape.fill(
                    Color.fallbackSystemBackground
                        .opacity(0.9)
                )
            }
            
            Color(white: 1, opacity: 0.01)
                .allowsHitTesting(true)
                .contentShape(shape)
        }
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
        
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            GlassToastBackground(
                accentColor: .blue,
                cornerRadius: 12,
                borderWidth: 2,
                isHovering: false,
                useTintedGlass: true,
                useInteractiveGlass: true
            )
            .padding(32)
            .border(Color.black)
            .padding()
        }
        
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
