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
        let thickness: MaterialToastStyle.MaterialThickness
        
        private var style: UIBlurEffect.Style {
            switch thickness {
            case .thin:
                return .systemThinMaterial
            case .regular:
                return .systemMaterial
            case .thick:
                return .systemThickMaterial
            }
        }
        
        func makeUIView(context: Context) -> UIVisualEffectView {
            UIVisualEffectView(effect: UIBlurEffect(style: style))
        }
        
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
#elseif canImport(UIKit) && os(watchOS)
    struct FallbackBackgroundEffectView: View {
        @Environment(\.colorScheme)
        private var colorScheme
        let thickness: MaterialToastStyle.MaterialThickness
        
        private var opacity: CGFloat {
            switch thickness {
            case .thin:
                return 0.33
            case .regular:
                return 0.66
            case .thick:
                return 0.88
            }
        }
        
        var body: some View {
            Color(white: colorScheme == .dark ? 0.15 : 0.95, opacity: opacity)
        }
    }
#elseif canImport(Cocoa)
    struct FallbackBackgroundEffectView: NSViewRepresentable {
        let thickness: MaterialToastStyle.MaterialThickness
        
        private var material: NSVisualEffectView.Material {
            switch thickness {
            case .thin:
                return .hudWindow
            case .regular:
                return .sidebar
            case .thick:
                return .headerView
            }
        }
        
        func makeNSView(context: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = material
            view.blendingMode = .withinWindow
            view.state = .active
            
            return view
        }
        
        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
            nsView.material = material
        }
    }
#endif
