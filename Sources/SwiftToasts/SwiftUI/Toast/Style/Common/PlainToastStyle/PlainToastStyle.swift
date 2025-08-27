//
//  PlainToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

public struct PlainToastStyle: ToastStyle {
    
    public nonisolated init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(configuration: configuration)
    }
    
    private struct StyledViewBody: View {
        @Environment(\.toastDismiss)
        private var toastDismiss
        
        @Environment(\.platformIdiom)
        private var platformIdiom
        
        @Environment(\.horizontalSizeClass)
        private var horizontalSizeClass
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        @Environment(\.toastInteractiveDismissEnabled)
        private var toastInteractiveDismissEnabled
        
        @State
        private var isHovering = false
        
        let configuration: Configuration
        
        init(configuration: Configuration) {
            self.configuration = configuration
        }
        
        private var accentColor: Color {
            switch configuration.role {
            case .plain:
                return Color.primary
            case .informational:
                return Color.blue
            case .success:
                return Color.green
            case .warning:
                return Color.yellow
            case .failure:
                return Color.red
            }
        }
        
        private var borderWidth: CGFloat {
            guard platformIdiom == .desktop || platformIdiom == .headset else {
                return isHovering ? 2 : 1
            }
            
            return isHovering ? 3 : 2
        }
        
        private var isCenterAligned: Bool {
            guard let toastPresentedAlignment else {
                return false
            }
            
            return toastPresentedAlignment.rawValue == [] || toastPresentedAlignment.rawValue == .all
        }
        
        var body: some View {
            configuration.content
                .applyToastControlStyles(
                    accentColor: accentColor
                )
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(
                    minWidth: platformIdiom == .watch ? nil : 180,
                    maxWidth: platformIdiom == .watch ? .infinity : nil,
                    alignment: isCenterAligned ? .center : .leading
                )
                .background(
                    PlainToastBackground(
                        accentColor: accentColor,
                        cornerRadius: 12,
                        borderWidth: borderWidth,
                        isHovering: isHovering
                    )
                )
                .platformDismissalGesture {
                    guard toastInteractiveDismissEnabled else {
                        return
                    }
                    
                    toastDismiss?()
                }
                .padding()
                .scaleEffect(isHovering ? 1.05 : 1)
#if !os(tvOS)
                .fallbackOnHover { isHovering = $0 }
#endif
                .animation(.default, value: isHovering)
                .accessibilityElement(children: .contain)
                .fallbackAccessibilityAddTraits([.isModal, .updatesFrequently])
                .fallbackAccessibilityIdentifier("Toast")
        }
    }
}

private extension View {
    
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

// MARK: ToastStyle Extension

public extension ToastStyle where Self == PlainToastStyle {
    
    static var plain: PlainToastStyle {
        PlainToastStyle()
    }
}

// MARK: Preview

#if DEBUG

struct PlainToastStylePreview: View {
    
    let previewableToastRoles: [ToastRole] = [.informational]
    
    var body: some View {
        VStack {
            ToastPresenterReader { proxy in
                Color.clear
                    .frame(minWidth: 100, minHeight: 100)
                    .onAppear {
                        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                            proxy.schedulePresentation(
                                toast: Toast(
                                    "Toast Title",
                                    value: "Subtitle",
                                    systemImage: "square.fill",
                                    duration: .indefinite
                                ),
                                toastAlignment: .center
                            )
                        }
                    }
            }
        }
    }
}

#Preview {
    PlainToastStylePreview()
        .environment(\.toastOrnamentPresentationEnabled, true)
}

#endif
