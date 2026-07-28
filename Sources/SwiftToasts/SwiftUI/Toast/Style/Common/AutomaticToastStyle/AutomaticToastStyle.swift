//
//  AutomaticToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 12/7/26.
//

import Foundation

public extension ToastStyle where Self == AnyToastStyle {
    
    nonisolated static var automatic: AnyToastStyle {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            return AnyToastStyle(.glass)
        } else {
            return AnyToastStyle(.material)
        }
    }
}
