//
//  PlainToastBackground.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/11/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

struct PlainToastBackground: View {
    
#if canImport(UIKit) && !os(watchOS)
    struct FallbackBackgroundEffectView: UIViewRepresentable {
        
        func makeUIView(context: Context) -> UIVisualEffectView {
            UIVisualEffectView(
                effect: UIBlurEffect(style: UIBlurEffect.Style.prominent)
            )
        }
        
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    }
#elseif canImport(UIKit) && os(watchOS)
    struct FallbackBackgroundEffectView: View {
        @Environment(\.colorScheme)
        private var colorScheme
        
        var body: some View {
            Color(white: colorScheme == .dark ? 0.15 : 0.95, opacity: 0.88)
        }
    }
#elseif canImport(Cocoa)
    struct FallbackBackgroundEffectView: NSViewRepresentable {
        
        func makeNSView(context: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = .sidebar
            view.blendingMode = .withinWindow
            view.state = .active
            
            return view
        }
        
        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
    }
#endif
    
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
    
    private var usesGlassBackgroundEffect: Bool {
#if os(visionOS)
        if toastOrnamentPresentationEnabled {
            return true
        }
#endif
        
#if BUILT_ON_XCODE_26
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            return true
        }
#endif
        
        return false
    }
    
    var body: some View {
        ZStack {
            if !usesGlassBackgroundEffect {
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
#if BUILT_ON_XCODE_26
        .fallbackGlassEffect(
            in: shape,
            enabled: usesGlassBackgroundEffect
        )
#endif
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
#if BUILT_ON_XCODE_26
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            return FallbackAnyShape(
                ConcentricRectangle(
                    corners: .concentric(
                        minimum: .fixed(cornerRadius)
                    )
                )
            )
        }
#endif
        return FallbackAnyShape(
            RoundedRectangle(
                cornerRadius: cornerRadius
            )
        )
    }
    
    @ViewBuilder
    private var material: some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 10.0, *) {
#if os(macOS)
            Rectangle()
                .fill(Material.ultraThickMaterial)
#elseif os(visionOS)
            Rectangle()
                .fill(Material.thinMaterial)
#else
            Rectangle()
                .fill(Material.regularMaterial)
#endif
        } else {
            FallbackBackgroundEffectView()
        }
    }
}

// MARK: Liguid Glass Material Support

#if BUILT_ON_XCODE_26

extension View {
    
    @ViewBuilder
    func fallbackGlassEffect<SomeShape: Shape>(
        in shape: SomeShape,
        enabled: Bool
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            self.glassEffect(enabled ? .regular.interactive() : .identity, in: shape)
        } else { // Fallback on earlier versions
            self
        }
    }
}

#endif

#if DEBUG

#Preview {
    VStack {
        Spacer()
        
        PlainToastBackground(
            accentColor: .blue,
            cornerRadius: 12,
            borderWidth: 2,
            isHovering: false
        )
        .onTapGesture {
            print("Tapped")
        }
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
