//
//  AccessibilityFocusModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 14/7/26.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct AccessibilityFocusModifier: ViewModifier {
    @Binding
    private var isFocused: Bool
    
    @AccessibilityFocusState
    private var isAccessibilityFocused: Bool
    
    init(isFocused: Binding<Bool>) {
        self._isFocused = isFocused
    }
    
    func body(content: Content) -> some View {
        content.accessibilityFocused($isAccessibilityFocused)
            .onChange(of: isAccessibilityFocused) { isAccessibilityFocused in
                isFocused = isAccessibilityFocused
            }
            .onChange(of: isFocused) { isFocused in
                isAccessibilityFocused = isFocused
            }
            .onAppear {
                isAccessibilityFocused = isFocused
            }
    }
}

struct FallbackAccessibilityFocusModifier: ViewModifier {
    @Binding
    private var isFocused: Bool
    
    init(isFocused: Binding<Bool>) {
        self._isFocused = isFocused
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard isFocused else { return }
            FallbackAccessibilityNotification.LayoutChanged.post(.toastView)
        }
        .fallbackOnChange(of: isFocused) { isFocused in
            if isFocused {
                FallbackAccessibilityNotification.LayoutChanged.post(.toastView)
            } else {
                FallbackAccessibilityNotification.ScreenChanged.post(nil)
            }
        }
    }
}

extension View {
    
    @ViewBuilder
    func fallbackAccessibilityFocused(_ isFocused: Binding<Bool>) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.modifier(AccessibilityFocusModifier(isFocused: isFocused))
        } else {
            self.modifier(FallbackAccessibilityFocusModifier(isFocused: isFocused))
        }
    }
}
