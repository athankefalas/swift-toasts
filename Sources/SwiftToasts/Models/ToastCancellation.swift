//
//  ToastCancellation.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// A type that represents the cancellation policy of a scheduled toast.
public enum ToastCancellation: Hashable, CaseIterable, Sendable {
    /// The scheduled toast will never be cancelled.
    case never
    
    /// The scheduled toast will be cancelled when the presentation of the source that scheduled it ends.
    case presentation
    
    /// The scheduled toast will be cancelled when a new toast is scheduled from the same source.
    case always
    
    /// The scheduled toast cancellation policy will be automatically selected.
    case automatic
    
    internal func byReplacingAutomatic(
        with value: ToastCancellation
    ) -> ToastCancellation {
        return self == .automatic ? value : self
    }
}
