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
        StyledViewBody(configuration: configuration) { properties in
            PlainToastBackground(
                accentColor: properties.accentColor,
                cornerRadius: properties.cornerRadius,
                borderWidth: properties.borderWidth,
                isHovering: properties.isHovering
            )
        }
    }
}

// MARK: ToastStyle Extension

public extension ToastStyle where Self == PlainToastStyle {
    
    static var plain: PlainToastStyle {
        PlainToastStyle()
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
