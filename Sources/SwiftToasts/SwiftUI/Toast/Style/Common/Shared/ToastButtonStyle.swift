//
//  ToastButtonStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/11/24.
//

import SwiftUI

@available(*, deprecated, message: "Do not use custom button style.")
struct ToastButtonStyle: ButtonStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(accentColor: accentColor, configuration: configuration)
    }
    
    private struct StyledViewBody: View {
        @Environment(\.isEnabled)
        private var isEnabled
        
        @Environment(\.toastDismiss)
        private var toastDismiss
        
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
                .opacity(configuration.isPressed ? 0.7 : 1)
                .scaleEffect(configuration.isPressed ? 0.9 : 1)
                .foregroundColor(foreground)
                .simultaneousTap {
                    toastDismiss?()
                }
        }
    }
}

struct ToastDismissReader<Content: View>: View {
    @Environment(\.toastDismiss)
    private var toastDismiss
    
    let content: (ToastDismissAction?) -> Content
    
    var body: some View {
        content(toastDismiss)
    }
}

extension View {
    
    func simultaneousTap(onEnded: @escaping () -> Void) -> AnyView {
        if #available(iOS 13.0, macOS 10.15, tvOS 16.0, watchOS 6.0, *) {
            AnyView(
                self.simultaneousGesture(
                    TapGesture(count: 1)
                        .onEnded {
                            onEnded()
                        }
                )
            )
        } else {
            AnyView(self)
        }
    }
    
    func applyToastButtonStyle(
        accentColor: Color
    ) -> some View {
        ToastDismissReader { dismissAction in
            self.foregroundColor(accentColor)
                .simultaneousTap {
                    dismissAction?()
                }
        }
    }
}
