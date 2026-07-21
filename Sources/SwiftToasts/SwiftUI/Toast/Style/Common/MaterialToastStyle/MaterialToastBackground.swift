//
//  MaterialToastBackground.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

struct MaterialToastBackground: View {
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
    let thickness: MaterialToastStyle.MaterialThickness
    
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
                if accessibilityReduceTransparency {
                    shape.fill(
                        Color.fallbackSystemBackground
                            .opacity(0.9)
                    )
                }
                
                material
                    .clipShape(shape)
                
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
            displayMode: usesGlassBackgroundEffect ? .always : .never
        )
#endif
        .shadow(
            color: usesGlassBackgroundEffect ? .clear : shadowColor,
            radius: usesGlassBackgroundEffect ? 0 : shadowRadius
        )
    }
    
    private var shape: FallbackAnyShape {
        return FallbackAnyShape(
            RoundedRectangle(
                cornerRadius: cornerRadius
            )
        )
    }
    
    private var material: AnyView {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 10.0, *) {
            let material: Material
            
            switch thickness {
            case .thin:
                material = .thinMaterial
            case .regular:
                material = .regularMaterial
            case .thick:
#if os(macOS)
                material = .ultraThickMaterial
#else
                material = .thickMaterial
#endif
            }
            
            return Rectangle()
                .fill(material)
                .erased()
        } else {
            return FallbackBackgroundEffectView(thickness: thickness)
                .erased()
        }
    }
}

#if ENABLE_PREVIEWS

#Preview {
    VStack {
        Spacer()
        
        MaterialToastBackground(
            accentColor: .blue,
            cornerRadius: 12,
            borderWidth: 2,
            isHovering: false,
            thickness: .thick
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
