//
//  GlassToastBackground.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 12/7/26.
//

import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
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
    
    var body: some View {
        ZStack {
            if false {
//                material
//                    .clipShape(shape)
                
                shape
                    .stroke(
                        accentColor.opacity(0.2),
                        lineWidth: borderWidth
                    )
                    .layoutPriority(-1)
            }
            
            Color(white: 1, opacity: 0.01)
                .allowsHitTesting(true)
                .contentShape(shape)
        }
#if os(visionOS)
        .glassBackgroundEffect(
            displayMode: .always
        )
#else
        .glassEffect(
            .regular
                .interactive()
                .tint(accentColor.opacity(0.33)),
            in: shape
        )
#endif
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
        
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            GlassToastBackground(
                accentColor: .blue,
                cornerRadius: 12,
                borderWidth: 2,
                isHovering: false
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
