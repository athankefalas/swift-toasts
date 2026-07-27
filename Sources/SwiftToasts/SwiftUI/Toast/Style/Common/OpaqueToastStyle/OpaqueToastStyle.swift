//
//  OpaqueToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

public struct OpaqueToastStyle: ToastStyle {
    private let useTintedBackground: Bool
    
    public nonisolated init(
        useTintedBackground: Bool = false
    ) {
        self.useTintedBackground = useTintedBackground
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            cornerRadius: 8,
            configuration: configuration
        ) { properties in
            OpaqueToastBackground(
                accentColor: properties.accentColor,
                cornerRadius: properties.cornerRadius,
                borderWidth: properties.borderWidth,
                isHovering: properties.isHovering,
                useTintedBackground: useTintedBackground
            )
        }
    }
}

// MARK: ToastStyle Extension

public extension ToastStyle where Self == OpaqueToastStyle {
    
    nonisolated static var opaque: OpaqueToastStyle {
        OpaqueToastStyle()
    }
}

// MARK: Preview

#if ENABLE_PREVIEWS

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
                                    role: .plain,
                                    duration: .indefinite
                                ),
                                toastAlignment: .center
                            )
                        }
                    }
            }
            .toastStyle(.plain)
        }
    }
}

#Preview {
    PlainToastStylePreview()
}

#endif
