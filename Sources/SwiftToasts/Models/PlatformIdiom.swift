//
//  PlatformIdiom.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/10/24.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

/// A type that can used to determine the platform device idiom.
public struct PlatformIdiom: Hashable, Sendable {
    private let rawValue: Int
    
    private init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let tv = PlatformIdiom(rawValue: 1)
    public static let car = PlatformIdiom(rawValue: 2)
    public static let phone = PlatformIdiom(rawValue: 3)
    public static let watch = PlatformIdiom(rawValue: 4)
    public static let tablet = PlatformIdiom(rawValue: 5)
    public static let desktop = PlatformIdiom(rawValue: 6)
    public static let headset = PlatformIdiom(rawValue: 7)
    public static let unknown = PlatformIdiom(rawValue: 0)
    
    @MainActor
    public static let current: PlatformIdiom = {
#if canImport(UIKit) && !os(watchOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .unspecified:
            return .unknown
        case .phone:
            return .phone
        case .pad:
            return .tablet
        case .tv:
            return .tv
        case .carPlay:
            return .car
        case .mac:
            return .desktop
        case .vision:
            return .headset
        @unknown default:
            return .unknown
        }
#elseif os(watchOS)
        return .watch
#elseif os(macOS)
        return .desktop
#else
        return .unknown
#endif
    }()
}
