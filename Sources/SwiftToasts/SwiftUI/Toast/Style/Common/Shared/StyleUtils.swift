//
//  StyleUtils.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

extension View {
    
    func applyToastControlStyles(
        accentColor: Color
    ) -> some View {
        self.applyToastLabelStyle(
            accentColor: accentColor
        )
        .applyToastLabeledContentStyle()
        .applyToastButtonStyle(
            accentColor: .accentColor
        )
        .font(.fallbackTitle3)
    }
    
    @ViewBuilder
    func platformDismissalGesture(
        perform action: @escaping () -> Void
    ) -> some View {
#if os(tvOS)
        if #available(tvOS 16, *) {
            self.onTapGesture(perform: action)
        } else {
            self
        }
#else
        self.onTapGesture(perform: action)
#endif
    }
}
