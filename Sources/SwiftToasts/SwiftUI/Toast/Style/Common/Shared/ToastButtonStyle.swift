//
//  ToastButtonStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/11/24.
//

import SwiftUI

struct ToastButtonStyle: PrimitiveButtonStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(accentColor: accentColor, configuration: configuration)
    }
    
    private struct StyledViewBody: View {
        @Environment(\.isEnabled)
        private var isEnabled
        
        @Environment(\.toastDismiss)
        private var toastDismiss
        
        @State
        private var namespace = UUID()
        
        @State
        private var size: CGSize?
        
        @State
        private var isPressed: Bool = false
        
        let accentColor: Color
        let configuration: Configuration
        
        var foreground: Color {
            guard isEnabled else {
                return .secondary.opacity(0.5)
            }
            
            return accentColor
        }
        
        var body: some View {
            configuration.label
                .opacity(isPressed ? 0.4 : 1)
                .scaleEffect(isPressed ? 0.9 : 1)
                .foregroundColor(foreground)
                .background(
                    Color.clear
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .fallbackOnChange(of: geometry.size) { newValue in
                                size = newValue
                            }
                            .onAppear {
                                size = geometry.size
                            }
                    }
                )
                .coordinateSpace(name: namespace.uuidString)
                .gesture(
                    buttonGesture,
                    isEnabled: isEnabled
                )
                .animation(.interactiveSpring, value: isPressed)
        }
        
        private var buttonGesture: some Gesture {
            DragGesture(minimumDistance: 0, coordinateSpace: .named(namespace.uuidString))
                .onChanged { value in
                    isPressed = effectiveButtonFrame.contains(value.location)
                }
                .onEnded { value in
                    defer {
                        isPressed = false
                    }
                    
                    guard effectiveButtonFrame.contains(value.location) else {
                        return
                    }
                    
                    withAnimation(.default) {
                        configuration.trigger()
                        toastDismiss?()
                    }
                }
        }
        
        private var effectiveButtonFrame: CGRect {
            CGRect(origin: .zero, size: size ?? .zero)
                .insetBy(dx: -16, dy: -16)
        }
    }
}

extension View {
    
    func applyToastButtonStyle(
        accentColor: Color
    ) -> some View {
        self.buttonStyle(ToastButtonStyle(accentColor: accentColor))
    }
}

#if ENABLE_PREVIEWS

#Preview {
    VStack(spacing: 32) {
        Button("Test System Style") {
            print("Button Action")
        }
        
        Button("Test Toast Style") {
            print("Button Action")
        }
        .buttonStyle(ToastButtonStyle(accentColor: .blue))
    }
    .environment(\.toastDismiss, ToastDismissAction(id: "", action: {
        print("Dismiss Toast.")
    }))
    .disabled(false)
}

#endif
