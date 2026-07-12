//
//  GlassToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct GlassToastStyle: ToastStyle {
    private let useTintedGlass: Bool
    private let useInteractiveGlass: Bool
    
    public nonisolated init(
        useTintedGlass: Bool = true,
        useInteractiveGlass: Bool = false
    ) {
        self.useTintedGlass = useTintedGlass
        self.useInteractiveGlass = useInteractiveGlass
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(configuration: configuration) { properties in
            GlassToastBackground(
                accentColor: properties.accentColor,
                cornerRadius: properties.cornerRadius,
                borderWidth: properties.borderWidth,
                isHovering: properties.isHovering,
                useTintedGlass: useTintedGlass,
                useInteractiveGlass: useInteractiveGlass
            )
        }
    }
}

// MARK: ToastStyle Extension

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public extension ToastStyle where Self == GlassToastStyle {
    
    nonisolated static var glass: GlassToastStyle {
        GlassToastStyle()
    }
}

// MARK: Preview

#if ENABLE_PREVIEWS

struct GlassToastStylePreview: View {
    
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
                                    role: .plain,
                                    duration: .indefinite
                                ),
                                toastAlignment: .center
                            )
                        }
                    }
            }
            .glassToastStyle(orElse: .material)
        }
    }
}

#Preview {
    GlassToastStylePreview()
}

#endif
