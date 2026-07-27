//
//  MaterialToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import SwiftUI

public struct MaterialToastStyle: ToastStyle {
    
    public nonisolated enum MaterialThickness: Sendable {
        case thin
        case regular
        case thick
        
        public static var automatic: MaterialThickness {
#if os(macOS)
            return .thick
#elseif os(visionOS)
            return .thin
#else
            return .regular
#endif
        }
    }
    
    private let thickness: MaterialThickness
    
    public nonisolated init(
        thickness: MaterialThickness = .automatic
    ) {
        self.thickness = thickness
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            cornerRadius: 12,
            configuration: configuration
        ) { properties in
            MaterialToastBackground(
                accentColor: properties.accentColor,
                cornerRadius: properties.cornerRadius,
                borderWidth: properties.borderWidth,
                isHovering: properties.isHovering,
                thickness: thickness
            )
        }
    }
}

// MARK: ToastStyle Extension

public extension ToastStyle where Self == MaterialToastStyle {
    
    @available(*, deprecated, renamed: "material")
    nonisolated static var plain: MaterialToastStyle {
        MaterialToastStyle()
    }
    
    nonisolated static var material: MaterialToastStyle {
        MaterialToastStyle()
    }
}

// MARK: Preview

#if ENABLE_PREVIEWS

struct MaterialToastStylePreview: View {
    
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
            .toastStyle(.material)
        }
    }
}

#Preview {
    MaterialToastStylePreview()
}

#endif
