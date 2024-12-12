//
//  ToastButtonStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/11/24.
//

import SwiftUI

struct ToastButtonStyle: ButtonStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(accentColor: accentColor, configuration: configuration)
    }
    
    private struct StyledViewBody: View {
        
        @Environment(\.isEnabled)
        private var isEnabled
        
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
