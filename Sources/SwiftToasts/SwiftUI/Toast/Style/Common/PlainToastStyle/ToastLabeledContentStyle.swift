//
//  ToastLabeledContentStyle.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 9/11/24.
//

import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct ToastLabeledContentStyle: LabeledContentStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(configuration: configuration)
    }
    
    private struct StyledViewBody: View {
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        let configuration: Configuration
        
        private var isCenterAligned: Bool {
            guard let toastPresentedAlignment else {
                return false
            }
            
            return toastPresentedAlignment.rawValue == [] || toastPresentedAlignment.rawValue == .all
        }
        
        var body: some View {
            VStack(
                alignment: isCenterAligned ? .center : .leading,
                spacing: isCenterAligned ? 8 : 4
            ) {
                configuration.label
                    .foregroundStyle(.primary)
                    .font(isCenterAligned ? .title : .title3)
                    .accessibilityIdentifier("ToastTitle")
                
                configuration.content
                    .foregroundStyle(.secondary)
                    .font(isCenterAligned ? .title3.weight(.regular) : .callout)
                    .accessibilityIdentifier("ToastSubtitle")
            }
        }
    }
}

extension View {
    
    @ViewBuilder
    func applyToastLabeledContentStyle() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.labeledContentStyle(ToastLabeledContentStyle())
        } else {
            self
        }
    }
}
