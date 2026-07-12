//
//  FallbackBackgroundEffectView.swift
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
