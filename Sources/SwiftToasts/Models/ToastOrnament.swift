//
//  ToastOrnament.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 3/12/24.
//

import SwiftUI

/// A type that is used as the owner for the ornament semantic toast presentation context.
///
/// - Note: In order to be compatible with view based presentation contexts, that are
/// assumed to be weak references and used as such by this library, this type is *self-referencial*.
/// Once it is used the `release` function **must** be invoked to avoid memory leaks.
@available(visionOS 1.0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public final class ToastOrnament {
    /// The content alignment used in the ornament
    public let contentAlignment: Alignment
    private var selfReference: ToastOrnament?
    
    public init(contentAlignment: Alignment) {
        self.contentAlignment = contentAlignment
        self.selfReference = self
    }
    
    /// Immediately releases the self reference.
    func release() {
        self.selfReference = nil
    }
}
