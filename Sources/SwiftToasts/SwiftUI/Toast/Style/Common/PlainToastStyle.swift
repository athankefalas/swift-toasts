//
//  PlainToastStyle.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//


import SwiftUI
import Combine

public struct PlainToastStyle: ToastStyle {
    
    public init() {}
    
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
        
        @Environment(\.accessibilityReduceTransparency)
        private var accessibilityReduceTransparency
        
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
            guard platformIdiom == .desktop else {
                return isHovering ? 2 : 1
            }
            
            return isHovering ? 3 : 2
        }
        
        private var shadowColor: Color {
            let shadowColor = Color(
                .sRGBLinear,
                white: 0,
                opacity: platformIdiom == .desktop ? 0.2 : 0.17
            )
            
            guard !accessibilityReduceTransparency else {
                return .clear
            }
            
            return shadowColor
        }
        
        private var shadowRadius: CGFloat {
            isHovering ? 24 : 16
        }
        
        var body: some View {
            configuration.content
                .applyToastLabelStyle(accentColor: accentColor)
                .applyToastLabeledContentStyle()
                .buttonStyle(ToastButtonStyle(accentColor: accentColor))
                .font(.fallbackTitle3)
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(minWidth: 180, alignment: .leading)
                .background(
                    Color.clear
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                )
                .platformDismissalGesture {
                    toastDismiss?()
                }
                .background(
                    PlainToastBackground(
                        accentColor: accentColor,
                        cornerRadius: 12,
                        borderWidth: borderWidth
                    )
                )
                .padding()
                .clipped()
                .shadow(
                    color: shadowColor,
                    radius: shadowRadius
                )
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

private struct ToastButtonStyle: ButtonStyle {
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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct ToastLabelStyle: LabelStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            accentColor: accentColor,
            configuration: configuration
        )
    }
    
    private struct StyledViewBody: View {
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        let accentColor: Color
        let configuration: Configuration
        
        private var isCenterAligned: Bool {
            guard let toastPresentedAlignment else {
                return false
            }
            
            return toastPresentedAlignment.rawValue == [] || toastPresentedAlignment.rawValue == .all
        }
        
        var body: some View {
            if isCenterAligned {
                VStack(spacing: 24) {
                    configuration.icon
                        .foregroundColor(accentColor)
                        .font(.largeTitle)
                        .accessibilityIdentifier("ToastIcon")
                    
                    configuration.title
                        .foregroundColor(.primary)
                        .font(.title)
                        .accessibilityIdentifier("ToastContent")
                        .accessibilityElement(children: .contain)
                }
            } else {
                HStack(spacing: 12) {
                    configuration.icon
                        .foregroundColor(accentColor)
                        .font(.title3)
                        .accessibilityIdentifier("ToastIcon")
                    
                    configuration.title
                        .foregroundColor(.primary)
                        .font(.title3)
                        .accessibilityIdentifier("ToastContent")
                        .accessibilityElement(children: .contain)
                }
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct ToastLabeledContentStyle: LabeledContentStyle {
    
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
                spacing: isCenterAligned ? 16 : nil
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

private extension View {
    
    @ViewBuilder
    func applyToastLabelStyle(
        accentColor: Color
    ) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.labelStyle(ToastLabelStyle(accentColor: accentColor))
        } else {
            self
        }
    }
    
    @ViewBuilder
    func applyToastLabeledContentStyle() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.labeledContentStyle(ToastLabeledContentStyle())
        } else {
            self
        }
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

extension ToastStyle where Self == PlainToastStyle {
    
    static var plain: PlainToastStyle {
        PlainToastStyle()
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .center, spacing: 16) {
            
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                ForEach(ToastRole.allCases, id: \.self) { role in
                    Toast("Title", value: "Subtitle", systemImage: "square.fill", role: role)
                }
            }
            
            Divider()
            
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                ForEach(ToastRole.allCases, id: \.self) { role in
                    Toast(role: role) {
                        LabeledContent("Title", value: "Subtitle")
                    }
                }
            }
            
            Divider()
            
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                ForEach(ToastRole.allCases, id: \.self) { role in
                    Toast("Title", systemImage: "square.fill", role: role)
                }
            }
            
            Divider()
            
            ForEach(ToastRole.allCases, id: \.self) { role in
                Toast("Title", role: role)
            }
            
            Divider()
            
        }
        .frame(maxWidth: .infinity)
    }
}
