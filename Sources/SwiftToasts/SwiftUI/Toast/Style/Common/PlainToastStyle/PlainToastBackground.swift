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
    
    @Environment(\.toastOrnamentPresentationEnabled)
    private var toastOrnamentPresentationEnabled
    
    let accentColor: Color
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    
    var body: some View {
        ZStack {
            if !toastOrnamentPresentationEnabled {
                material
                    .clipShape(shape)
                
                shape
                    .stroke(
                        accentColor.opacity(0.2),
                        lineWidth: borderWidth
                    )
                    .layoutPriority(-1)
            } else {
                Color.clear
            }
        }
#if os(visionOS)
        .glassBackgroundEffect(
            displayMode: toastOrnamentPresentationEnabled ? .always : .never
        )
#endif
    }
    
    private var shape: some Shape {
        RoundedRectangle(
            cornerRadius: cornerRadius
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

#if DEBUG

#Preview {
    VStack {
        Spacer()
        
        PlainToastBackground(
            accentColor: .blue,
            cornerRadius: 12,
            borderWidth: 2
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
