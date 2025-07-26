//
//  ToastPresentationInvalidationOptions.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 26/7/25.
//

import Foundation

/// A type that represents the invalidation options of an already presented toast.
public struct ToastPresentationInvalidationOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// The active toast presentation is never invalidated.
    public static let never: ToastPresentationInvalidationOptions = []
    
    /// The active toast presentation is invalidated when the context changes and when the source presentation is dismissed.
    public static let all: ToastPresentationInvalidationOptions = [.contextChanged, .presentationDismissed]
    
    /// The active toast presentation is invalidated when it's context changes.
    /// - Note: The context applies to the value that triggered the toast to be presented.
    public static let contextChanged = ToastPresentationInvalidationOptions(rawValue: 1 << 0)
    
    /// The active toast presentation is invalidated when it's source presentation is dismissed.
    public static let presentationDismissed = ToastPresentationInvalidationOptions(rawValue: 1 << 1)
}
