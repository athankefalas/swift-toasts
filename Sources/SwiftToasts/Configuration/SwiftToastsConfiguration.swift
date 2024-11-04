//
//  SwiftToastsConfiguration.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 23/10/24.
//

import Foundation

/// A type that can be used to configure the behaviour of toast presentation.
@MainActor
public class SwiftToastsConfiguration: Sendable {
    
    /// A type that encapsulates the time scale used as a factor in the duration of toast presentations.
    /// - Note: TimeScale values must be in the [0,2] range inclusive, with 1 representing the normal time scale.
    public struct TimeScale: RawRepresentable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, Sendable {
        public let rawValue: Double
        
        public init(rawValue: Double) {
            self.rawValue = max(min(rawValue, 2), 0)
        }
        
        public init(floatLiteral value: Double) {
            self.init(rawValue: value)
        }
        
        public init(integerLiteral value: Int) {
            self.init(rawValue: Double(value))
        }
        
        public static let immediate = TimeScale(rawValue: 0)
        public static let normal = TimeScale(rawValue: 1)
        public static let slow = TimeScale(rawValue: 2)
    }
    
    public static let current = SwiftToastsConfiguration()
    
    var timeScale: TimeScale = 1
    public var presentationContextSelector = ToastPresentationContextSelector.scenePresentation
    
    private init() {}
}
