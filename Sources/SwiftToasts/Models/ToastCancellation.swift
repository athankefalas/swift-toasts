//
//  ToastCancellation.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// A type that represents the cancellation policy of a toast.
public enum ToastCancellation: Hashable, CaseIterable, Sendable {
    /// The toast will never be cancelled.
    case never
    
    /// The toast will be cancelled when the presentation of the source that scheduled it ends.
    case presentation
    
    /// The toast will be cancelled when a new toast is scheduled from the same source.
    case always
    
    /// The cancellation policy will be automatically selected.
    case automatic
    
    internal func byReplacingAutomatic(
        with value: ToastCancellation
    ) -> ToastCancellation {
        return self == .automatic ? value : self
    }
}
